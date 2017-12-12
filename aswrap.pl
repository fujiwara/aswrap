#!/usr/bin/env perl

use strict;
use warnings;

use Config::Tiny;
use JSON::PP qw/ decode_json /;

my $profile = $ENV{AWS_PROFILE} || $ENV{AWS_DEFAULT_PROFILE};
set_env($profile) if defined $profile;
exec @ARGV;

sub set_env {
    my $profile = shift;
    my $config  = Config::Tiny->read("$ENV{HOME}/.aws/credentials") or return;
    my $section = $config->{$profile} or return;
    my $src     = $section->{source_profile} or return;
    my $role    = $section->{role_arn} or return;
    my $output  = qx{aws --output json --profile "$src" sts assume-role --role-arn "$role" --role-session-name temp};
    chomp $output;
    my $res = decode_json($output);
    if (my $cred = $res->{Credentials}) {
        delete $ENV{AWS_PROFILE};
        delete $ENV{AWS_DEFAULT_PROFILE};
        $ENV{AWS_ACCESS_KEY_ID}     = $cred->{AccessKeyId};
        $ENV{AWS_SECRET_ACCESS_KEY} = $cred->{SecretAccessKey};
        $ENV{AWS_SESSION_TOKEN}     = $cred->{SessionToken};
    }
    $ENV{AWS_REGION} = $section->{region} if defined $section->{region};
    return;
}
