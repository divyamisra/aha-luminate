/* jshint strict:false */

module.exports = {
  options: {
    optimizationLevel: 3
  },

  "general": {
    files: [
      {
        expand: true,
        cwd: 'src/general/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/general/image/'
      }
    ]
  },

  "heart-walk": {
    files: [
      {
        expand: true,
        cwd: 'src/heart-walk/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/heart-walk/image/'
      }
    ]
  },

  "youth-markets": {
    files: [
      {
        expand: true,
        cwd: 'src/youth-markets/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/youth-markets/image/'
      }
    ]
  },

  "ym-primary": {
    files: [
      {
        expand: true,
        cwd: 'src/ym-primary/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}',
          'prizes/*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}',
          'prizes2020/*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}',
          'prizes2021/*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}',
          'fy21/*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/ym-primary/image/'
      }
    ]
  },

  "middle-school": {
    files: [
      {
        expand: true,
        cwd: 'src/middle-school/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/middle-school/image/'
      }
    ]
  },

  "high-school": {
    files: [
      {
        expand: true,
        cwd: 'src/high-school/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/high-school/image/'
      }
    ]
  },

  "district-heart": {
    files: [
      {
        expand: true,
        cwd: 'src/district-heart/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/district-heart/image/'
      }
    ]
  },

  "nchw": {
    files: [
      {
        expand: true,
        cwd: 'src/nchw/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/nchw/image/'
      }
    ]
  },

  "heartchase": {
    files: [
      {
        expand: true,
        cwd: 'src/heartchase/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/heartchase/image/'
      }
    ]
  },

  "cyclenation": {
    files: [
      {
        expand: true,
        cwd: 'src/cyclenation/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/cyclenation/image/'
      }
    ]
  },

  "heartwalk2020": {
    files: [
      {
        expand: true,
        cwd: 'src/heartwalk2020/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/heartwalk2020/image/'
      }
    ]
  },

  "fieldday": {
    files: [
      {
        expand: true,
        cwd: 'src/fieldday/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/fieldday/image/'
      }
    ]
  },

  "heartwalklawyers": {
    files: [
      {
        expand: true,
        cwd: 'src/heartwalklawyers/image/',
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ],
        dest: 'dist/heartwalklawyers/image/'
      }
    ]
  }
}
