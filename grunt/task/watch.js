/* jshint strict:false */

require('events').EventEmitter.prototype._maxListeners = 100;

module.exports = {
  "grunt-config": {
    files: [
      'Gruntfile.coffee',
      'grunt/task/*.js',
      'grunt/.jshintrc'
    ],
    tasks: [
      'jshint:grunt-config',
      'notify:grunt-config'
    ]
  },

  "global": {
    files: [
      'src/global/sass/**/*',
      'src/global/coffee/**/*',
      'src/global/html/**/*'
    ],
    tasks: [
      'notify:global'
    ]
  },

  "general": {
    files: [
      'src/global/sass/**/*',
      'src/global/coffee/**/*',
      'src/global/html/**/*',
      'src/general/sass/**/*',
      'src/general/coffee/**/*',
      'src/general/html/**/*',
      'src/general/image/**/*'
    ],
    tasks: [
      'clean:general',
      'css-dist:general',
      'js-dist:general',
      'html-dist:general',
      'img-copy:general-images',
      'notify:general'
    ]
  },

  "heart-walk": {
    files: [
      'src/global/html/**/*',
      'src/global/sass/**/*',
      'src/global/coffee/**/*',
      'src/heart-walk/html/**/*',
      'src/heart-walk/image/**/*',
      'src/heart-walk/sass/**/*',
      'src/heart-walk/coffee/**/*'
    ],
    tasks: [
      'clean:heart-walk',
      'css-dist:heart-walk',
      'js-dist:heart-walk',
      'html-dist:heart-walk',
      'translation-copy:heart-walk-translations',
      'img-copy:heart-walk-images',
      'notify:heart-walk'
    ]
  },

  "youth-markets": {
    files: [
      'src/youth-markets/html/**/*',
      'src/youth-markets/image/**/*'
    ],
    tasks: [
      'clean:youth-markets',
      'html-dist:youth-markets',
      'img-copy:youth-markets-images',
      'notify:youth-markets'
    ]
  },

  "nchw": {
    files: [
      'src/nchw/html/**/*',
      'src/nchw/image/**/*',
      'src/nchw/sass/**/*',
      'src/nchw/js/**/*'
    ],
    tasks: [
      'clean:nchw',
      'css-dist:nchw',
      'js-dist:nchw',
      'html-dist:nchw',
      'img-copy:nchw-images',
      'notify:nchw'
    ]
  },

  "heartchase": {
    files: [
      'src/heartchase/html/**/*',
      'src/heartchase/image/**/*',
      'src/heartchase/sass/**/*',
      'src/heartchase/js/**/*'
    ],
    tasks: [
      'clean:heartchase',
      'css-dist:heartchase',
      'js-dist:heartchase',
      'html-dist:heartchase',
      'img-copy:heartchase-images',
      'notify:heartchase'
    ]
  },

  "cyclenation": {
    files: [
      'src/cyclenation/html/**/*',
      'src/cyclenation/image/**/*',
      'src/cyclenation/sass/**/*',
      'src/cyclenation/js/**/*'
    ],
    tasks: [
      'clean:cyclenation',
      'css-dist:cyclenation',
      'js-dist:cyclenation',
      'html-dist:cyclenation',
      'img-copy:cyclenation-images',
      'notify:cyclenation'
    ]
  },
  "heartwalk2020": {
    files: [
      'src/heartwalk2020/html/**/*',
      'src/heartwalk2020/image/**/*',
      'src/heartwalk2020/sass/**/*',
      'src/heartwalk2020/js/**/*'
    ],
    tasks: [
      'clean:heartwalk2020',
      'css-dist:heartwalk2020',
      'js-dist:heartwalk2020',
      'html-dist:heartwalk2020',
      'img-copy:heartwalk2020-images',
      'notify:heartwalk2020'
    ]
  },
  "fieldday": {
    files: [
      'src/fieldday/html/**/*',
      'src/fieldday/img/**/*',
      'src/fieldday/sass/**/*',
      'src/fieldday/js/**/*',
      'src/fieldday/webfonts/**/*'
    ],
    tasks: [
      'clean:fieldday',
      'css-dist:fieldday',
      'js-dist:fieldday',
      'html-dist:fieldday',
      'img-copy:fieldday-images',
      'notify:fieldday'
    ]
  },
  "fieldday2023": {
    files: [
      'src/fieldday2023/html/**/*',
      'src/fieldday2023/image/**/*',
      'src/fieldday2023/sass/**/*',
      'src/fieldday2023/webfonts/**/*',
      'src/fieldday2023/js/**/*'
    ],
    tasks: [
      'clean:fieldday2023',
      'css-dist:fieldday2023',
      'js-dist:fieldday2023',
      'html-dist:fieldday2023',
      'img-copy:fieldday2023-images',
      'notify:fieldday2023'
    ]
  },
  "heartwalklawyers": {
    files: [
      'src/heartwalklawyers/html/**/*',
      'src/heartwalklawyers/image/**/*',
      'src/heartwalklawyers/sass/**/*',
      'src/heartwalklawyers/js/**/*'
    ],
    tasks: [
      'clean:heartwalklawyers',
      'css-dist:heartwalklawyers',
      'js-dist:heartwalklawyers',
      'html-dist:heartwalklawyers',
      'img-copy:heartwalklawyers-images',
      'notify:heartwalklawyers'
    ]
  },
  "leaders-for-life": {
    files: [
      'src/leaders-for-life/html/**/*',
      'src/leaders-for-life/image/**/*',
      'src/leaders-for-life/sass/**/*',
      'src/leaders-for-life/js/**/*'
    ],
    tasks: [
      'clean:leaders-for-life',
      'css-dist:leaders-for-life',
      'js-dist:leaders-for-life',
      'html-dist:leaders-for-life',
      'img-copy:leaders-for-life-images',
      'notify:leaders-for-life'
    ]
  },
  "social-stem": {
    files: [
      'src/social-stem/html/**/*',
      'src/social-stem/image/**/*',
      'src/social-stem/sass/**/*',
      'src/social-stem/js/**/*'
    ],
    tasks: [
      'clean:social-stem',
      'css-dist:social-stem',
      'js-dist:social-stem',
      'html-dist:social-stem',
      'img-copy:social-stem-images',
      'notify:social-stem'
    ]
  },
  "women-of-impact": {
    files: [
      'src/women-of-impact/html/**/*',
      'src/women-of-impact/image/**/*',
      'src/women-of-impact/sass/**/*',
      'src/women-of-impact/js/**/*'
    ],
    tasks: [
      'clean:women-of-impact',
      'css-dist:women-of-impact',
      'js-dist:women-of-impact',
      'html-dist:women-of-impact',
      'img-copy:women-of-impact',
      'notify:women-of-impact'
    ]
  },
  "teens-of-impact": {
    files: [
      'src/teens-of-impact/html/**/*',
      'src/teens-of-impact/image/**/*',
      'src/teens-of-impact/sass/**/*',
      'src/teens-of-impact/js/**/*'
    ],
    tasks: [
      'clean:teens-of-impact',
      'css-dist:teens-of-impact',
      'js-dist:teens-of-impact',
      'html-dist:teens-of-impact',
      'img-copy:teens-of-impact',
      'notify:teens-of-impact'
    ]
  }
}
