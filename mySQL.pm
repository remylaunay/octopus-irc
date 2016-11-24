package mySQL;

sub connect{
    my $user_db = 'remylaunay';
    my $password_db = '*';
    my $base_name = 'octopus';
    my $mysql_host_url = 'x.x.x.x';

    my $dsn = "DBI:mysql:$base_name:$mysql_host_url";
    my $dbh = DBI->connect($dsn, $user_db, $password_db) or die $DBI::errstr;

    return $dbh;
}

sub disconnect{
	
}

1;
