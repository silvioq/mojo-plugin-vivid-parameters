use 5.010001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Mojolicious::Plugin::VividParams',
    VERSION_FROM      => 'lib/Mojolicious/Plugin/VividParams.pm', # finds $VERSION
    PREREQ_PM         => { Mojolicious => 1.41 }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Mojolicious/Plugin/VividParams.pm', # retrieve abstract from module
       AUTHOR         => 'Silvio <silvio@gmail.com>') : ()),
    test => {TESTS => 't/*.t t/*/*.t'}
);
