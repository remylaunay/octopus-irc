use MIME::Base64;

my $ip = "109.190.32.65";
my @part = split(/\./, $ip);
my $res = pack("C*",@part);
print encode_base64($res);

