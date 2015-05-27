use lib 'lib';
use HTTP::Server::Logger;
use Test;

plan 1;

class test {
  has $.last is rw = '';
  method middleware(Sub $r) {
    $.last = $r(class { 
      has $.method   = 'GET';
      has $.resource = '/', 
      has $.version  = 'HTTP/1.0' 
    }.new, class { 
      has $.status   = 200, 
      has $.bytes    = 20,
    }.new);
  }
};

my $a = test.new;
hook $a;

ok $a.last ~~ / ^^ 'unavailable - - ' \d ** 2 '/' \w ** 3 '/' \d ** 4 ':' \d ** 2 ':' \d ** 2 ':' \d ** 2 ' ' ('+'|'-') \d ** 4 ' "GET / HTTP/1.0" 200 20' $$ /, 'Format matches';
