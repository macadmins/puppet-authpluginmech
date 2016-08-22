node default {
    # Going to have a bad time without crypt installed
    package { 'crypt-2.0.0.28':
        ensure   => 'installed',
        provider => 'pkgdmg',
        source   => 'https://github.com/grahamgilbert/crypt2/releases/download/2.0.0.28/Crypt-2.0.0.28.pkg'
    }
    
    authpluginmech { 'Crypt:Check,privileged':
        ensure       => 'present',
        insert_after => 'MCXMechanism:login'
    } ->
    authpluginmech { 'Crypt:CryptGUI':
        ensure       => 'present',
        insert_after => 'Crypt:Check,privileged'
    } ->
    authpluginmech { 'My awesome mech':
        ensure       => 'present',
        entry        => 'Crypt:Enablement,privileged',
        insert_after => 'Crypt:CryptGUI'
    }
}
