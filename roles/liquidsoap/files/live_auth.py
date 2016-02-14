#!/usr/bin/env python2

import argparse
import logging
import logging.handlers
import sys
import ConfigParser
import hashlib
import sqlalchemy
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.schema import Sequence, ForeignKey, Index, UniqueConstraint


session = None
logger = logging.getLogger(__name__)

Base = declarative_base()


class HarborLogin(Base):
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    channel = Column(String, nullable=False)
    digest = Column(String, nullable=False)
    # if null, enabled
    disabled = Column(DateTime, nullable=True)

    __tablename__ = 'harborlogins'
    __table_args__ = (Index('oneHarborLoginPass', name, channel, digest, unique=True), )

    def __init__(self, name, channel, pw):
        self.name = name
        self.channel = channel
        digest = hashlib.sha1(pw).hexdigest()
        self.digest = digest
        self.disabled = None

    def password(self, password):
        self.digest = hashlib.sha1(password).hexdigest()

    def disable(self):
        self.disabled = sqlalchemy.func.now()

    def enable(self):
        self.disabled = None

    def __repr__(self):
        if self.disabled:
            return "<DisabledHarborLogin('{0}')>".format(self.name)
        return "<HarborLogin('{0}')>".format(self.name)


def logindecorator(wrapped):
    def wrappee(user, channel, password):
        login = session.query(HarborLogin).filter(
            HarborLogin.channel == channel,
            HarborLogin.name == user).first()
        ret = wrapped(login, password)
        session.add(login)
        session.flush()
        session.commit()
        return ret
    return wrappee


def displaydecorator(wrapped):
    def wrappee(*args, **kwargs):
        out = wrapped(*args, **kwargs)
        if out is True:
            print('true')
            return True
        print('false')
        return False
    return wrappee


@displaydecorator
def authenicate(user, channel, password):
    digest = hashlib.sha1(password).hexdigest()
    #logger.info('Checking for login {0}/{1}({2}'.format(user, channel, digest))
    users = session.query(HarborLogin).filter(
        HarborLogin.disabled == None,  # noqa
        HarborLogin.channel == channel,
        HarborLogin.digest == digest)
    if users.count() == 0:
        logger.warn('Failed login {0} on {1} with {2}'.format(user, channel, digest))
        return False
    #logger.info('Successful login {0} on {1}'.format(user, channel))
    return True


@displaydecorator
def add_login(user, channel, password):
    login = HarborLogin(user, channel, password)
    session.add(login)
    session.flush()
    session.commit()


@logindecorator
@displaydecorator
def disable_login(login, password):
    login.disable()
    return True


@logindecorator
@displaydecorator
def set_password(login, password):
    login.password(password)
    login.enable()
    return True


def options():
    """
    * set all default options
    * scan command line for config file option
    * then load any default & cli specified config files
    * then override with any other command line options
    """
    # built in default options
    defaults = {
        "interval": 60,
        "verbosity": 0,
        "logfile": None,
    }

    # scan argv for config file option
    conf_parser = argparse.ArgumentParser(
        # Turn off help, so we print all options in response to -h
        add_help=False
    )
    conf_parser.add_argument("-c", "--conf_file",
                             help="Specify config file", metavar="FILE")
    args, remaining_argv = conf_parser.parse_known_args()

    # argv specified config file
    conf_files = ['/etc/live_auth.cfg', './live_auth.cfg']
    if args.conf_file:
        conf_files.append(args.conf_file)

    try:
        config = ConfigParser.SafeConfigParser()
        config.read(conf_files)
        defaults.update(config.items("defaults"))
    except ConfigParser.NoSectionError:
        logger.debug('NoSectionError default config files')

    # process the rest of the argv
    # Don't surpress add_help here so it will handle -h
    parser = argparse.ArgumentParser(
        # Inherit options from config_parser
        parents=[conf_parser],
        # print script description with -h/--help
        description=__doc__,
        # Don't mess with format of description
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.set_defaults(**defaults)
    parser.add_argument('-v', dest='verbosity', help='verbosity', action='count')
    parser.add_argument('-q', dest='verbosity', help='silence!', action='store_const', const=-2)
    parser.add_argument('--dbengine', help='database connection string', action='store')
    parser.add_argument('--dbecho', help='database debug flag', action='store_true')
    parser.add_argument('--logfile', help='where to chat about whats going on', action='store')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--add', dest='action', help='when you want to add a new user/channel', action='store_const', const='add')
    group.add_argument('--rm', dest='action', help='remove user/channel', action='store_const', const='rm')
    group.add_argument('--unlock', dest='action', help='set the password & unlock', action='store_const', const='pw')
    parser.add_argument('channel', help='the channel name')
    parser.add_argument('username', help='the user name')
    parser.add_argument('password', nargs='?', help='the password')
    return(parser.parse_args(remaining_argv))


if __name__ == '__main__':
    opts = options()
    logger.setLevel(logging.DEBUG)
    # Add the log message handler to the logger
    if opts.logfile:
        formatter = logging.Formatter('%(asctime)s [%(name)s] %(levelname)s - %(message)s')
        fhandler = logging.handlers.RotatingFileHandler(
            opts.logfile, maxBytes=1048576, backupCount=5)
        fhandler.setFormatter(formatter)
        fhandler.setLevel(logging.DEBUG)
        logger.addHandler(fhandler)
    chandler = logging.StreamHandler(stream=sys.stdout)
    chandler.setLevel(40-(int(opts.verbosity)*10))
    #if opts.verbosity < 0:
    #    chandler.setLevel(logging.CRITICAL)
    logger.addHandler(chandler)

    engine = create_engine(opts.dbengine, echo=opts.dbecho)
    Session = sessionmaker(bind=engine)
    session = Session()
    Base.metadata.create_all(engine)

    actions = {
        'add': add_login,
        'rm': disable_login,
        'pw': set_password,
    }
    if opts.action in actions:
        sys.exit(actions[opts.action](opts.username, opts.channel, opts.password))
    sys.exit(authenicate(opts.username, opts.channel, opts.password))
