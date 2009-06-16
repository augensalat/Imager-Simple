use inc::Module::Install;
 
name		'Imager::Simple';
license		'perl';
all_from	'lib/Imager/Simple.pm';
author		'Bernhard Graf <graf@cpan.org>';

build_requires  'Test::More';
 
requires	'Carp';
requires	'Class::Accessor::Fast';
requires	'Imager';
requires	'Scalar::Util';
 
WriteAll;
