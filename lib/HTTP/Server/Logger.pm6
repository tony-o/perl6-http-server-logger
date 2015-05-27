unit module HTTP::Server::Logger;

my @fmt = '%h %l %u %t "%r" %>s %b'.split(' ');

multi sub format(Str $fmt) is export {
  @fmt = $fmt.split(' ');
}

multi sub format(%data) is export {
  my $str = '';
  for @fmt <-> $f {
    for %data.keys -> $d {
      $f .=subst("$d", %data{$d});
    }
    $str ~= "$f ";
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
      '%t'  => "{sprintf('%2d', $time.day)}/{@mont[$time.month]}/{sprintf('%04d', $time.year)}:{sprintf('%02d',$time.hour)}:{sprintf('%02d',$time.minute)}:{sprintf('%02d',$time.second)} {$*TZ < 0 ?? '-' !! '+'}{sprintf('%04d', ($*TZ/3600).abs * 100)}",
      '%r'  => "{$req.method // 'ERR'} {$req.resource // ''} {$req.version // ''}",
      '%>s' => $res.status // '-1',
      '%b'  => $res.bytes // '-',
      '%B'  => $res.bytes // '0',
    });
    $fmt.say;
    return $fmt;
  });
}
