#!/usr/bin/perl
use strict;
use XML::Simple;
#use Data::Dumper;


# Be sure to create a file containing your api_key called 'api_key.txt' in this directory
my $api_key = `cat api_key.txt`;
chomp $api_key;
if (! $api_key) { die "Please provide an API key in a file called 'api_key.txt' in this directory"; }

my $api_server = 'api-na.hosted.exlibrisgroup.com';

my $search = `curl -s 'https://$api_server/almaws/v1/conf/jobs?apikey=$api_key&profile_id=7562275960001401&category=FULFILLMENT'`;

my $job_ref = XMLin($search);
#print Dumper($ref);

my $job = $job_ref->{job}{id};

system ("curl -s -o meyer2.xml 'https://$api_server/almaws/v1/conf/jobs/$job?apikey=$api_key'");