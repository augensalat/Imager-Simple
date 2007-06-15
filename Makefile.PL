use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Imager::Simple',
    AUTHOR              => 'Bernhard Graf <graf@movingtarget.de>',
    VERSION_FROM        => 'lib/Imager/Simple.pm',
    ABSTRACT_FROM       => 'lib/Imager/Simple.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Carp' => 0,
        'Scalar::Util' => 0,
        'Class::Accessor::Fast' => 0,
        'Imager' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Imager-Simple-*' },
);
