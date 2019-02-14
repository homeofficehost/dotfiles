module.exports = {
  brew: [
    // Program that can automate interactive applications
    'expect',
    // Search tool like grep, but optimized for programmers - http://conqueringthecommandline.com/book/ack_ag
    'ack',
    'ag',
    // alternative to `cat`: https://github.com/sharkdp/bat
    'bat', 
    // Install GNU core utilities (those that come with macOS are outdated)
    'coreutils',
    'dos2unix',
    // Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
    'findutils --with-default-names',
    // 'fortune',
    'fzf',
    'readline', // ensure gawk gets good readline
    // GNU awk utility
    'gawk',
    // http://www.lcdf.org/gifsicle/ (because I'm a gif junky)
    'gifsicle',
    // GNU Pretty Good Privacy (PGP) package
    'gnupg',
    // C code prettifier
    'gnu-indent --with-default-names',
    // Install GNU `sed`, overwriting the built-in `sed`
    // so we can do "sed -i 's/foo/bar/' file" instead of "sed -i '' 's/foo/bar/' file',
    // GNU implementation of the famous stream editor
    'gnu-sed --with-default-names',
    // GNU version of the tar archiving utility
    'gnu-tar --with-default-names',
    // GNU implementation of which utility
    'gnu-which --with-default-names',
    // upgrade grep so we can get things like inverted match (-v)
    'grep --with-default-names',
    // better, more recent grep
    'homebrew/dupes/grep',
    // https://github.com/jkbrzt/httpie
    'httpie',
    // Mac App Store CLI: https://github.com/mas-cli/mas
    'mas',
    // Install some other useful utilities like `sponge`
    'moreutils',
    'binutils',
    'diffutils',
    // GNU Transport Layer Security (TLS) Library
    'gnutls',
    // World's fastest and most advanced password recovery utility
    'hashcat',
    // Bash script to format a block device to UDF
    'format-udf',
    // GNU Emacs text editor
    'emacs',
    // Free (GNU) replacement for the Pico text editor
    'nano',
    // Port scanning utility for large networks
    'nmap',
    'openconnect',
    'reattach-to-user-namespace',
    // better/more recent version of screen
    'homebrew/dupes/screen',
    'tmux',
    'todo-txt',
    'tree',
    'ttyrec',
    // Vi 'workalike' with many additional features
    'vim --with-override-system-vi',
    // Executes a program periodically, showing output fullscreen
    'watch',
    // Install wget with IRI support
    'wget --enable-iri',
    // Interpreted, interactive, object-oriented programming language
    'python',
    // Open source programming language to build simple/reliable/efficient software
    'go',
    // Highly capable, feature-rich programming language
    'perl@5.18',
    // Platform built on V8 to build network applications
    'node',
    // Ruby version manager
    'rbenv',
    'ruby',
    // Lightweight DNS forwarder and DHCP server
    'dnsmasq',
    // Drop-in replacement for MySQL
    'mariadb',
    // Object-relational database system
    'postgresql',
    // Persistent key-value database, with built-in net interface
    'redis',
    // Classic UNIX line editor
    'ed --with-default-names',
    // AdoptOpenJDK main binary releases for OpenJDK 10 with HotSpot
    'adoptopenjdk-openjdk10',
    // Download with resuming and segmented downloading
    'aria2',
    // General-purpose data compression with high compression ratio
    'xz',
    // Official Amazon AWS command-line interface
    'awscli',
    // Bourne-Again SHell, a UNIX command interpreter
    'bash',
    // Dependency Manager for PHP
    'composer',
    // Asynchronous event library
    'libevent',
    // Monitor DHCP traffic for debugging purposes
    'dhcpdump',
    // Perl lib for reading and writing EXIF metadata
    'exiftool',
    // Play, record, convert, and stream audio and video
    'ffmpeg',
    // Utility to determine file types
    'file-formula',
    // Distributed revision control system
    'git',
    // Git extension for versioning large files
    'git-lfs',
    // Configure transparent encryption of files in a Git repo
    'transcrypt',
    // Ruby client and CLI for GitLab API
    'gitlab-gem',
    // Version Control Visualization Tool
    'gource',
    // Apply a diff file to an original
    'gpatch',
    // Colorize logfiles and command output
    'grc',
    // C/C++ and Java libraries for Unicode and globalization
    'icu4c',
    // Popular GNU data compression program
    'gzip',
    // Improved top (interactive process viewer)
    'htop',
    // Add GitHub support to git on the command-line
    'hub',
    // Image processing tools collection
    'graphicsmagick',
    // Tools and libraries to manipulate images in many formats
    'imagemagick',
    // Convert JPG images to ASCII
    'jp2a',
    // Tool to capture still images from an iSight or other video source
    'imagesnap',
    // Lightweight and flexible command-line JSON processor
    'jq',
    // Pager program similar to more
    'less',
    // List USB devices, just like the Linux lsusb command
    'lsusb',
    // Text-based web browser
    'lynx',
    // Macro processing language
    'm4',
    // Utility for directing compilation
    'make',
    // High-performance, schema-free, document-oriented database
    'mongodb',
    // Recursively compute digests on files/directories
    'md5deep',
    // Fast and user friendly build system
    'meson',
    // Lightweight text-to-speech engine based on CMU Flite
    'mimic',
    // Text to speech, software speech synthesizer
    'espeak',
    'prettyping',
    // Scriptable ping program for checking if multiple hosts are up
    'fping',
    // HTTP(S) server and reverse proxy, and IMAP/POP3 proxy server
    'nginx',
    // 'traceroute' and 'ping' in a single tool
    'mtr',
    // Web server scanner
    'nikto',
    // Password generator
    'pwgen',
    // OpenBSD freely-licensed SSH connectivity tools
    'openssh',
    // Shell command parallelization utility
    'parallel',
    // Tool to automatically fix PHP coding standards issues
    'php-cs-fixer',
    // Programmer-oriented testing framework for PHP
    'phpunit',
    // Rsync for cloud storage
    'rclone',
    // Unit testing tool
    'roundup',
    // Utility that provides fast incremental file transfer
    'rsync',
    // Diff images from the command-line
    'spaceman-diff',
    // Sparklines for the shell
    'spark',
    // Command-line interface for https://speedtest.net bandwidth tests
    'speedtest-cli',
    // Command-line tool to manage your ssh connections
    'stormssh',
    // Bring your .bashrc, .vimrc, etc. with you when you SSH
    'sshrc',
    // Simplified and community-driven man pages
    'tldr',
    // Display directories as trees (with optional color/HTML output)
    'tree',
    // Extract, view, and test RAR archives
    'unrar',
    // Extraction utility for .zip compressed archives
    'unzip',
    // Display word differences between text files
    'wdiff',
    // Download YouTube videos from the command-line
    'youtube-dl',
    // The Dart SDK
    'dart-lang/dart/dart',
    // Everything you need to get started with Heroku
    'heroku/brew/heroku',
    // Command-line interface for WordPress
    'wp-cli',
    // HTTP benchmarking tool
    'wrk',
    // Fish-like fast/unobtrusive autosuggestions for zsh
    'zsh-autosuggestions',
  ],
  cask: [
    'balenaetcher',
    'brave',
    'ccleaner',
    'cryptomator',
    'disk-inventory-x',
    'docker',
    'dropbox',
    'dbvisualizer',
    'firefox',
    'flux',
    'gitup',
    'google-chrome',
    'integrity',
    'istumbler',
    'iterm2',
    'java',
    'jdownloader',
    'keka',
    'dupeguru',
    'iina',
    'qtpass',
    'keybase',
    'macs-fan-control',
    'mongohub',
    'mysqlworkbench',
    'numi',
    'onyx',
    'opera',
    'osxfuse',
    'parsehub',
    'phpstorm',
    'postman',
    'rocket-chat',
    'robomongo',
    'sdformatter',
    'sequel-pro',
    'postico',
    'spectacle',
    'sqlitebrowser',
    'srware-iron',
    'sublime-text',
    'telegram',
    'torbrowser',
    'transmission',
    'vlc',
    'vnc-viewer',
    'transmit-disk',
    'karabiner-elements',
    'gpg-suite'
  ],
  gem: [
  ],
  npm: [
    '@vue/cli',
    'vuepress',
    'eslint',
    'eslint-config-standard',
    'ngrok',
    'codeceptjs',
    'puppeteer',
    'redis-commander',
    // SysAdmin
    'npm-check',
    'fkill-cli',
    'vtop',
    'gtop',
    'kill-tabs',
    'iponmap',
    'spoof',
    'osx-wifi-cli',
    'wifi-password-cli',
    // Audit
    'siteaudit',
    'why-is-node-running',
    // Deploy
    'netlify-cli',
    'now',
    'surge',
    // Human Tools
    'prettyaml',
    'yamlxjson',
    // Automation Driven Development
    '@rafaelrinaldi/whereami',
    'gitmoji-cli',
    'git-open',
    'filepizza',
    'shorturl',
    'npms-cli',
    'get-urls-cli',
    'wallpaper-cli',
    'trash-cli',
    'empty-trash-cli',
    'torrent',
    // Text Development
    'pen',
    'carbon-now-cli',
    'instant-markdown-d',
    'prettyjson',
    // Fun
    'buzzphrase',
  ],
  mas: [
    '409201541', // Pages
    '497799835', // Xcode
    '824183456', // Affinity Photo
    '824171161', // Affinity Designer
  ]
};
