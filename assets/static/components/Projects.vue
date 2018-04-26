<template lang="pug">
  #projects
    h1 Projects
</template>

<script>
export default {
  name: 'projects',
  data: () => ({
    projects: [],
    errors: null
  }),

  created(){
     this.$http.get('/api/projects').then(response => {
       this.projects = response.body
     }, error => {
       // error callback
       this.errors = error.body.errors
     })
  }
}
</script>

<style lang="scss">
</style>
