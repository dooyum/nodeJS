module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'koemei-widget.json'
    banner:'/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
        '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
        '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
        '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
        ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n'

    clean:
      src: [
        'dist'
        'src/koemei/js/'
        'src/koemei/templates/js'
        'src/koemei/templates/html'
      ]
      spec: ['spec/js']

    stylus:
      files:
        expand: true
        cwd: "src/koemei/style/stylus"
        src: [
          "**/*.styl"
          "!modules/**/*.styl"
        ]
        dest: 'src/koemei/style'
        ext: '.css'

    imageEmbed:
      dist:
        src: [ "src/koemei/style/widget.css" ]
        dest: "dist/<%= pkg.name %>.css"
        options:
          deleteAfterEncoding : false
          maxImageSize: 0

    concat:
      options:
        banner:'<%= banner %>'
        stripBanners:true
      all:
        files:
          'dist/<%= pkg.name %>.js': [
            'src/libs/jquery/jquery.js',
            'src/libs/jwplayer.js',
            'src/libs/video.min.js',
            'src/libs/underscore-min.js',
            'src/libs/backbone.js',
            'src/libs/keymaster.min.js',
            'src/libs/scope_start.js',
            'src/libs/handlebars.js',
            'src/libs/backbone.shortcuts.min.js',
            'src/libs/jquery/jquery-ui-1.10.2.custom.js',
            'src/libs/jquery/ZeroClipboard.min.js',
            'src/libs/jquery/moment.js',
            'src/libs/jquery/livestamp.js',
            'src/libs/easyXDM.min.js',
            'src/libs/jquery/jquery.topzindex.min.js',
            'src/libs/jquery/jquery.md5.js',
            'src/libs/jquery/jquery.tipsy.js',
            'src/libs/jquery/jquery.mousewheel.js',
            'src/libs/jquery/jquery.carouFredSel-6.0.5-packed.js',
            'src/libs/jquery/jquery.joyride-2.0.3.js',
            'src/libs/editor/*.js',
            'src/koemei/js/koemei.js',
            'src/koemei/js/util.js',
            'src/koemei/templates/js/**/*.js',
            'src/koemei/js/model/**/*.js',
            'src/koemei/js/collection/**/*.js',
            'src/koemei/js/view/**/*.js',
            'src/koemei/js/player_interfaces/*.js',
            'src/koemei/koemei.widget.js',
            '!src/koemei/js/config.js',
            'src/libs/scope_end.js'
          ]
        nonull: true

    uglify:
      options:
        banner: '<%= banner %>'
      dist:
        src: 'dist/<%= pkg.name %>.js'
        dest: 'dist/<%= pkg.name %>.min.js'


    coffee:
      options:
        bare: true
      glob_to_multiple:
        expand: true,
        cwd: 'src/koemei/coffee'
        src: ['**/*.coffee']
        dest: 'src/koemei/js'
        ext: '.js'
      src:
        expand: true
        cwd: 'spec/coffee'
        src: '**/*.coffee'
        dest: 'spec/js/'
        ext: '.js'
      spec:
        expand: true
        cwd: 'spec/coffee'
        src: '**/*.coffee'
        dest: 'spec/js/'
        ext: '.js'

    coffeelint:
      dist: ['<%= coffee.src.cwd %>/**/*.coffee']
      spec: ['spec/**/*.coffee']
      options :
        'max_line_length':
          level: 'ignore'
          value: 120
        'no_trailing_whitespace':
          level: 'ignore'

    jade:
      #options:
        #debug: true
        #compileDebug: false
      files:
        expand: true
        cwd: "src/koemei/templates/jade"
        src: ["**/*.jade"]
        dest: 'src/koemei/templates/html'
        ext: '.html'

    handlebars:
      options:
        #namespace: "Koemei.Templates"
        processName: (filePath) ->
         # set the nameof the jst function to ucfirst
         fileParts = filePath.split('/')
         fileNameParts = fileParts[fileParts.length - 1].split('.')
         fileNameParts[0].charAt(0).toUpperCase() + fileNameParts[0].substr(1);
      files:
        expand: true
        cwd: "src/koemei/templates/html"
        src: ["**/*.html"]
        dest: 'src/koemei/templates/js'
        ext: '.js'

    watch:
      coffee:
        files: ['<%= coffee.glob_to_multiple.cwd %>/**/*.coffee']
        tasks: ['coffeelint', 'coffee']
      stylus:
        files: ['<%= stylus.files.cwd %>/**/*.styl']
        tasks: ['stylus']
      jade:
        files: ["<%= jade.files.cwd %>/**/*.jade"]
        tasks: ['jade']
      handlebars:
        files: ["<%= handlebars.files.cwd %>/**/*.html"]
        tasks: ['handlebars', 'concat']
      concat:
        files: [
          "src/koemei/**/*.js"
          "src/koemei/style/**/*.css"
        ]
        tasks: ['concat', 'imageEmbed']

    play:
      error:
        file: 'doc/error.mp3'
        
    # this is not the proper way and will be replaced soon!
    # i tried to use the `concat` task as the base for this, but didn't work...
    #TODO: use requirejs to load scripts in the right order
    jasmine:
      options:
        keepRunner: true
        outfile: 'SpecRunner.html'
      all:
        src: [
          'src/libs/jquery/jquery.js',
          'src/libs/jwplayer.js',
          'src/libs/underscore-min.js',
          'src/libs/backbone.js',
          'src/libs/keymaster.min.js',
          #'src/libs/scope_start.js',
          'src/libs/handlebars.js',
          'src/libs/backbone.shortcuts.min.js',
          'src/libs/jquery/jquery-ui-1.10.2.custom.js',
          'src/libs/jquery/ZeroClipboard.min.js',
          'src/libs/jquery/moment.js',
          'src/libs/jquery/livestamp.js',
          'src/libs/easyXDM.min.js',
          'src/libs/jquery/jquery.topzindex.min.js',
          'src/libs/jquery/jquery.md5.js',
          'src/libs/jquery/jquery.tipsy.js',
          'src/libs/jquery/jquery.mousewheel.js',
          'src/libs/jquery/jquery.carouFredSel-6.0.5-packed.js',
          'src/libs/jquery/jquery.joyride-2.0.3.js',
          'src/libs/editor/*.js',
          'src/koemei/js/koemei.js',
          'src/koemei/js/util.js',
          'src/koemei/templates/js/**/*.js',
          'src/koemei/js/model/**/*.js',
          'src/koemei/js/collection/**/*.js',
          'src/koemei/js/view/**/*.js',
          'src/koemei/js/player_interfaces/*.js',
          'src/koemei/koemei.widget.js',
          '!src/koemei/js/config.js',
          #'src/libs/scope_end.js'
        ]
        options:
          specs: ['spec/js/*.js']

  # Load the plugins.
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-qunit'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks "grunt-image-embed"
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-handlebars'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-play'

  # Default tasks.
  grunt.registerTask 'full', ['stylus', 'clean', 'coffeelint:dist', 'coffee:glob_to_multiple', 'jade', 'handlebars', 'concat:all', 'uglify', 'imageEmbed', 'play:success']

  grunt.registerTask 'quick', ['stylus', 'clean', 'coffeelint:dist', 'coffee:glob_to_multiple', 'jade', 'handlebars', 'concat:all', 'imageEmbed', 'play:success']

  grunt.registerTask 'default', ['quick', 'watch']
