<template lang="pug">
  #project
    .info(v-if="project")
      h1 {{project}}
    .error_404(v-else="")
      <md-toolbar class="md-accent">
        <h3 class="md-title">Project not found</h3>
      </md-toolbar>

      <b>Would you like to go on <router-link to="/projects"> Projects </router-link> page?</b>


</template>

<script>
export default {
  name: 'projects',
  data: () => ({
    errors: null,
  }),

  computed: {
    project(){
      return this.$store.getters.currentProject(this.$route.params.project_id)[0]
    },
  }

}
</script>

<style lang="scss">
#project{
  .error_404{
    margin: 20px;
    .md-accent{
      width: 250px;
      margin: auto;
    }
  }
  h3{
    margin: auto;
  }
}

</style>
