component {
  this.mappings = {
    '/root' = getDirectoryFromPath( getCurrentTemplatePath() ),
    '/wirebox' = getDirectoryFromPath( getCurrentTemplatePath() ) & 'wirebox'
  }
}