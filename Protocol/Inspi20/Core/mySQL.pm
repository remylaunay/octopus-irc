package mySQL;

sub connect{
    my $user_db = 'remylaunay';
    my $password_db = '28a5dh';
    my $base_name = 'octopus';
    my $mysql_host_url = '91.134.235.115';

    my $dsn = "DBI:mysql:$base_name:$mysql_host_url";
    my $dbh = DBI->connect($dsn, $user_db, $password_db) or die $DBI::errstr;

    return $dbh;
}

sub disconnect{
	
}

1;