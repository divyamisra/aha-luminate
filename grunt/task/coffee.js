/* jshint strict:false */

module.exports = {
  options: {
    join: true
  },
  
  "general": {
    files: {
      'dist/general/js/main.js': [
        'src/general/coffee/init.coffee',
        'src/global/coffee/config/*.*',
        'src/general/coffee/config/*.*',
        'src/global/coffee/service/*.*',
        '!src/global/coffee/service/trpc-*.*',
        'src/general/coffee/service/*.*',
        'src/global/coffee/directive/*.*',
        'src/general/coffee/directive/*.*',
        'src/general/coffee/**/*.*'
      ]
    }
  },
  
  "heart-walk": {
    files: {
      'dist/heart-walk/js/main.js': [
        'src/heart-walk/coffee/init.coffee',
        'src/global/coffee/config/*.*',
        'src/heart-walk/coffee/config/*.*',
        '!src/heart-walk/coffee/config/trpc-*.*',
        '!src/heart-walk/coffee/config/trPageEdit-*.*',
        'src/global/coffee/service/*.*',
        '!src/global/coffee/service/trpc-*.*',
        'src/heart-walk/coffee/service/*.*',
        '!src/heart-walk/coffee/service/trpc-*.*',
        '!src/heart-walk/coffee/service/trPageEdit-*.*',
        'src/global/coffee/directive/*.*',
        'src/heart-walk/coffee/directive/*.*',
        '!src/heart-walk/coffee/directive/trpc-*.*',
        '!src/heart-walk/coffee/directive/trPageEdit-*.*',
        'src/heart-walk/coffee/**/*.*',
        '!src/heart-walk/coffee/**/trpc-*.*',
        '!src/heart-walk/coffee/**/trPageEdit-*.*'
      ],
      'dist/heart-walk/js/participant.js': [
        'src/heart-walk/coffee/trpc-init.coffee',
        'src/heart-walk/coffee/config/trpc-*.*',
        'src/global/coffee/service/trpc-*.*',
        'src/heart-walk/coffee/**/trpc-*.*'
      ],
      'dist/heart-walk/js/pageEdit.js': [
        'src/heart-walk/coffee/trPageEdit-init.coffee',
        'src/heart-walk/coffee/config/trPageEdit-*.*',
        'src/global/coffee/service/trPageEdit-*.*',
        'src/heart-walk/coffee/**/trPageEdit-*.*'
      ]
    }
  },
 
  "heartchase": {
    files: {
      'dist/heartchase/js/main.js': [
        'src/jump-hoops/coffee/init.coffee',
        'src/jump-hoops/coffee/config/*.*',
        'src/global/coffee/service/*.*',
        'src/youth-markets/coffee/service/*.*',
        'src/youth-markets/coffee/controller/*.*',
        'src/jump-hoops/coffee/service/*.*',
        'src/global/coffee/directive/*.*',
        'src/jump-hoops/coffee/directive/*.*',
        'src/jump-hoops/coffee/**/*.*',
      ]
    }
  }
}
