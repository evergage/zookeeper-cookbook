name             'zookeeper'
maintainer       'Jeff Byrnes'
maintainer_email 'thejeffbyrnes@gmail.com'
license          'Apache-2.0'
description      'Installs/Configures zookeeper'
version          '15.0.0'
chef_version     '>= 16.0'

issues_url 'https://github.com/jeffbyrnes/zookeeper-cookbook/issues'
source_url 'https://github.com/jeffbyrnes/zookeeper-cookbook/'

supports         'ubuntu', '>= 18.04'
supports         'centos', '>= 7.0'
supports         'redhat', '>= 7.0'

depends          'java', '~> 11.1'
depends          'magic', '>= 1.1'
depends          'ark', '~> 6.0'
