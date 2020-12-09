node default {
    # Going to have a bad time without crypt installed
    # package { 'crypt-2.0.0.28':
    #     ensure   => 'installed',
    #     provider => 'pkgdmg',
    #     source   => 'https://github.com/grahamgilbert/crypt2/releases/download/2.0.0.28/Crypt-2.0.0.28.pkg'
    # }

    if munki_item_installed('Crypt'){
        $ensure = 'present'
    } else {
        $ensure = 'absent'
    }

    if $facts['os']['macosx']['version']['major'] == '10.12' {
        $insert_after = 'CryptoTokenKit:login'
    } else {
        $insert_after = 'MCXMechanism:login'
    }

    authpluginmech { 'Crypt:Check,privileged':
        ensure       => $ensure,
        insert_after => $insert_after
    } ->
    authpluginmech { 'Crypt:CryptGUI':
        ensure       => $ensure,
        insert_after => 'Crypt:Check,privileged'
    } ->
    authpluginmech { 'Crypt:Enablement,privileged':
        ensure       => $ensure,
        insert_after => 'Crypt:CryptGUI'
    }
}
