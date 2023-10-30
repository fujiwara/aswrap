#!/usr/bin/env perl

use strict;
use warnings;

use Config::Tiny;
use JSON::PP qw/ decode_json /;

my $profile = $ENV{AWS_PROFILE} || $ENV{AWS_DEFAULT_PROFILE};
if (defined $profile) {
    set_env_assume_role($profile); # || set_env_sso($profile);
}
if (@ARGV) {
    exec @ARGV;
}
for my $key (qw/AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_REGION/) {
    if (my $value = $ENV{$key}) {
        print "export $key=$value\n";
    }
}

sub set_env_assume_role {
    my $profile = shift;
    my $section
        = find_role_profile("$ENV{HOME}/.aws/credentials", $profile)
        || find_role_profile("$ENV{HOME}/.aws/config", "profile $profile")
        || return;
    my $src_profile_opt = "";
    if (my $src = $section->{source_profile}) {
        $src_profile_opt = qq{--profile "$src"};
    }
    my $role    = $section->{role_arn};
    my $session = "aswrap-session-" . time();
    my $mfa     = read_token($section->{mfa_serial}) || '';
    my $output  = qx{aws --output json $src_profile_opt sts assume-role --role-arn "$role" --role-session-name "$session" $mfa};
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
    return 1;
}

sub find_role_profile {
    my ($path, $profile) = @_;
    my $config  = Config::Tiny->read($path) or return;
    my $section = $config->{$profile}       or return;
    $section->{role_arn} or return;
    return $section;
}

sub read_token {
    my $mfa_serial = shift;
    return unless $mfa_serial;

    print STDERR "MFA Code: ";
    system "stty", "-echo";  # echo back off
    my $token = <STDIN>;
    system "stty", "echo";   # echo back on
    chomp($token);
    return unless $token =~ /^(\d{6})$/xms;

    return qq{--serial-number "$mfa_serial" --token-code "$token"};
}
