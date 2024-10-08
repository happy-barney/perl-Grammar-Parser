
# This file was automatically generated by Dist::Zilla::Plugin::ModuleBuild v6.032.
use strict;
use warnings;

use Module::Build 0.28;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.28"
  },
  "configure_requires" => {
    "Module::Build" => "0.28"
  },
  "dist_abstract" => "Simplified grammar description",
  "dist_author" => [
    "Branislav Zahradn\x{ed}k <barney\@cpan.org>"
  ],
  "dist_name" => "Grammar-Parser",
  "dist_version" => "1.0.0",
  "license" => "artistic_2",
  "module_name" => "Grammar::Parser",
  "recursive_test_files" => 1,
  "requires" => {
    "perl" => "5.014",
    "warnings" => 0
  },
  "test_requires" => {
    "Test::YAFT" => 0
  }
);


my %fallback_build_requires = (
  "Module::Build" => "0.28",
  "Test::YAFT" => 0
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  delete $module_build_args{test_requires};
  $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);


$build->create_build_script;
