unit module HTTP::Server::Logger;

use DateTime::Format;

my $format  = '%h %l %u %t "%r" %>s %b'.split(' ');

multi sub format(Str $fmt) is export {
  $format = $fmt;
}

multi sub format(%data) is export {
  my $str = '';
  while $format ~~ m:c/ ( <!after '\\'> '%' ) $<status>=['!'? [\d+ % ',']+ ]? $<param>=[ \{ .+? \} ]**0..1 $<code>=\w / {
    my $status = $<status>.subst(/^'!'/,'');
    my $param  = $<param>.substr(1,*-1);
    my $code   = $<code>;
  }
  return $str.trim;
}

sub hook($app) is export {
  $app.middleware(sub ($req, $res) {
    my $time = DateTime.new(time, :timezone($*TZ));
    my @mont = qw<Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec>;
    my $fmt  = format({
      '%h'  => try { $res.connection.remote_address; } // 'unavailable',
      '%l'  => '-',
      '%u'  => '-',
      '%t'  => strftime('%d/%b/%Y:%k:%M:%S %z', $time),
      '%r'  => "{$req.method // 'ERR'} {$req.resource // ''} {$req.version // ''}",
      '%>s' => $res.status // '-1',
      '%b'  => $res.bytes // '-',
      '%B'  => $res.bytes // '0',
    });
    $fmt.say;
    return $fmt;
  });
}
