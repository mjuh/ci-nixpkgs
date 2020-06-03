#! ${pkgs.nix}/bin/nix-shell
#! nix-shell -I nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos -i perl -p  perl perlPackages.ListAllUtils

use List::AllUtils qw(sum);

my ( $group , $name_of_cgroup , %full_hash_users , $upper_tresh_cpu_shares , $upper_tresh_io_weight , $tresh_la ) ;
my $down_tresh_io_weight = 10 ;
my $down_tresh_cpu_shares = 10 ;

if (scalar @ARGV != 1 ) {
         $ARGV[0] = 70 ;
}

$tresh_la = $ARGV[0] ;

open(my $fh, '<:encoding(UTF-8)', '/etc/cgconfig.conf' )
    or die "Could not open file , cgconfig is not configured $!";
while (<$fh>) {
    chomp  ;
    my @fields = split / = / ;
    if ( $fields[0] =~ m/cpu.shares/ ) { $upper_tresh_cpu_shares = $fields[1] };
    if ( $fields[0] =~ m/blkio.weight/ ) { $upper_tresh_io_weight = $fields[1] };
    $upper_tresh_cpu_shares  =~ s/[^0-9]// ;
    $upper_tresh_io_weight  =~ s/[^0-9]// ;
}
close $fh;

open(my $fh, '<:encoding(UTF-8)', '/etc/cgrules.conf' )
    or die "Could not open file , cgrules is not configured $!";
while (<$fh>) {
    chomp;
    my @fields = split /\s+/ ;
    $group = $fields[0] ;
    $group =~ s/^@// ;
    $name_of_cgroup = $fields[2] ;
    $name_of_cgroup  =~ s/\/%u// ;
    close $fh;
}

sub avg { return @_ ? sum(@_) / @_ : 0 }

sub get_la {
    open(LOAD, "/proc/loadavg") or die "Unable to get server load \n";
    my $load_avg = <LOAD>;
    close LOAD;
    my ( $one_min_avg ) = split /\s/, $load_avg;
    chomp ;
    return $one_min_avg;
}

sub get_my_users {
    my @users;
    open(my $fh, '<:encoding(UTF-8)', '/etc/passwd' ) # need to set custom (from containers) passwd
        or die "Could not open file  $!";
    while (<$fh>) {
        chomp  ;
        my @fields = split /:/ ;
#        if ( $fields[4] =~ m/Hosting/ && $fields[6] =~ m/bash/ ) { @users = ( @users, $fields[0] ); };
        if ( $fields[4] =~ m/Hosting/ && $fields[6] =~ m/bash/ ) { @users = ( @users, $fields[2] ); }; # use uid instead username
    }
    close $fh;
    return @users ;
}

sub set_cgroup_user_stats {
    my ( $controller , $cgroup_name , $username , $cgroup_file , $value ) = @_ ;
    my $filename = sprintf("/cgroup/%s/%s/%s/%s", $controller , $cgroup_name , $username , $cgroup_file ) ;
    if ( -e $filename &&  defined $username  ) {
        open(my $fh, '>', $filename );
        print $fh int($value) ;
        close $fh;
        return ;
    }
}

sub get_cgroup_user_stats {
    my ( $controller , $cgroup_name , $username , $cgroup_file ) = @_ ;
    my $filename = sprintf("/cgroup/%s/%s/%s/%s", $controller , $cgroup_name , $username , $cgroup_file ) ;
    if ( -e $filename ) {
        open(my $fh, '<:encoding(UTF-8)', $filename )
            or die "Could not open file '$filename' $!";
        if ( $cgroup_file eq "blkio.throttle.io_service_bytes" ) {
            while (<$fh>) {
                chomp;
                my @fields = split /\s+/;
                if ($fields[0] =~ m/^Total/ ) {
                    $total = $fields[1];
                    return int ($total) ;
                    last ;
                }

            }
        }
        else {
            my $value = <$fh>;
            chomp ;
            return int ( $value)  ;
        }
    }
    else {
    }
    return 0 ;
}

sub add_to_hash {
    my $user = shift ;
    my %hash ;
    $hash{$user}{name} = $user ;
    $hash{$user}{blkio}{throttle.io_service_bytes} = get_cgroup_user_stats ( "blkio" , $name_of_cgroup , $user , "blkio.throttle.io_service_bytes" ) ;
    $hash{$user}{blkio}{blkio.weight} = get_cgroup_user_stats ( "blkio" , $name_of_cgroup , $user , "blkio.weight" ) ;
    $hash{$user}{cpu}{cpu.shares} =  get_cgroup_user_stats ( "cpu" , $name_of_cgroup , $user , "cpu.shares" ) ;
    $hash{$user}{cpuacct}{cpuacct.usage} =  get_cgroup_user_stats ( "cpuacct" , $name_of_cgroup , $user , "cpuacct.usage" ) ;
    return %hash ;
}

sub get_all_users_hash {
    my %users ;
    foreach my $user (get_my_users($group)) {
        %users = ( %users , add_to_hash($user) );
    }
    return %users ;
}

sub top_usage_accs_by_avg {
    my %hash = @_ ;
    my @cpuspeed ;
    my @blkiospeed ;
    my @winner_blk_speed ;
    my @winner_cpuacct_speed ;
    foreach my $users (sort keys %hash) {
       @cpuspeed = (@cpuspeed, $hash{$users}{cpuacct}{cpuspeed} ) ;
       @blkiospeed = (@blkiospeed, $hash{$users}{blkio}{blkiospeed} ) ;
    }  

    my $avgcpuspeed = avg(@cpuspeed) ;
    my $avgblkiospeed = avg(@blkiospeed) ;

    foreach my $users (sort keys %hash) {
        if ($hash{$users}{cpuacct}{cpuspeed} > $avgcpuspeed  ) {
            @winner_cpuacct_speed = (@winner_cpuacct_speed ,  $hash{$users}{name} ) ;
        }
        if ($hash{$users}{blkio}{blkiospeed} > $big_blkiospeed ) {
            @winner_blk_speed = (@winner_blk_speed ,  $hash{$users}{name} ) ;
        }
    }
    return (\@winner_blk_speed, \@winner_cpuacct_speed);
}

sub main {
    my %prv_iter = get_all_users_hash() ;
    my %full_hash_users ;
    while(47) {
        my %users = get_all_users_hash() ;
        my @users_temp = get_my_users () ;
        for my $user (@users_temp) {
            $full_hash_users{$user}{name} = $users{$user}{name} ;
            $full_hash_users{$user}{blkio}{throttleio_service_bytes} =  $users{$user}{blkio}{throttleio_service_bytes} ;
            $full_hash_users{$user}{blkio}{blkioweight} =  $users{$user}{blkio}{blkioweight}  ;
            my $blkiospeed = $users{$user}{blkio}{throttleio_service_bytes} - $prv_iter{$user}{blkio}{throttleio_service_bytes} ;
            $full_hash_users{$user}{blkio}{blkiospeed} = $blkiospeed ;
            my $cpuspeed = $users{$user}{cpuacct}{cpuacctusage} - $prv_iter{$user}{cpuacct}{cpuacctusage} ;
            $full_hash_users{$user}{cpuacct}{cpuspeed} = $cpuspeed ;
            $full_hash_users{$user}{cpuacct}{cpuacctusage} =  $users{$user}{cpuacct}{cpuacctusage} ;
            $full_hash_users{$user}{cpu}{cpu.shares} =  $users{$user}{cpu}{cpu.shares} ;
            if ( $full_hash_users{$user}{blkio}{blkioweight} < $upper_tresh_io_weight ) {
                set_cgroup_user_stats ( "blkio" , $name_of_cgroup , $user , "blkio.weight" , int ($full_hash_users{$user}{blkio}{blkioweight} + 1 )  ) ;
            }
            if ( $full_hash_users{$user}{cpu}{cpu.shares} < $upper_tresh_cpu_shares ) {
                set_cgroup_user_stats ( "cpu" , $name_of_cgroup , $user , "cpu.shares" , int ( $full_hash_users{$user}{cpu}{cpu.shares} + 1 ) ) ;
            }
        }
        my $la =  get_la() ;
        if ( $la > $tresh_la ) {
            my ($huge_accs_blk , $huge_accs_cpu ) = top_usage_accs_by_avg (%full_hash_users) ;
            for my $user (@$huge_accs_blk) {
                set_cgroup_user_stats ( "blkio" , $name_of_cgroup , $user , "blkio.weight" , $down_tresh_io_weight ) ;
            }
            for my $user (@$huge_accs_cpu) {
                set_cgroup_user_stats ( "cpu" , $name_of_cgroup , $user , "cpu.shares" , $down_tresh_cpu_shares ) ;
            }

        }

        %prv_iter = %users ;
        sleep 60 ;
    }

}

main();
die ;
