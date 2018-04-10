/* jshint strict:false */

module.exports = {
  "general-images": {
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
  
  "heart-walk-translations": {
    files: [
      {
        expand: true, 
        cwd: 'src/heart-walk/translation/', 
        src: [
          '*.json', 
          '**/*.json'
        ], 
        dest: 'dist/heart-walk/translation/'
      }
    ]
  }, 
  
  "heart-walk-images": {
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
  
  "youth-markets-images": {
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
  
  "jump-hoops-images": {
    files: [
      {
        expand: true, 
        cwd: 'src/jump-hoops/image/', 
        src: [
          '*.{gif,GIF,jpg,JPG,png,PNG,svg,SVG}'
        ], 
        dest: 'dist/jump-hoops/image/'
      }
    ]
  }, 
  
  "middle-school-images": {
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
  
  "high-school-images": {
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
  
  "district-heart-images": {
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
  "nchw-images": {
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
  "nchw-scripts": {
    files: [
      {
        expand: true,
        cwd: 'src/nchw/js/',
        src: [
          '*.js'
        ],
        dest: 'dist/nchw/js/'
      }
    ]
  }
}