<template lang="pug">
  #project
    .info(v-if="project")
      h1 {{project.name}}

      <div class="md-layout md-gutter">
        <div class="md-layout-item md-size-60">
          .emails
            .item(v-for="email in emails")
              | {{email}}

        </div>
        <div class="md-layout-item md-size-40">
          .credentials
            <md-list class="md-double-line">
              <md-subheader>Credentials</md-subheader>
              <md-list-item>
                <span class="md-list-item-text">
                  span.content {{project.key}}
                  span Key
                </span>
              </md-list-item>

              <md-list-item>
                <span class="md-list-item-text">
                  span.content {{project.secret}}
                  span Secret
                </span>
              </md-list-item>
            </md-list>
        </div>
      </div>


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
    emails(){
      this.$http.get('/api/emails', {params: {project_id: this.$route.params.project_id}}).then(response => {
        //this.$store.dispatch('SET_PROJECTS', response.body.data)
        console.log(response)
      }, error => {
        // error callback
        this.errors = error.body.errors
      })
    }
  },

}
</script>

<style lang="scss">
#project{
  .credentials{

    span.content{
      background: #f7f7f7;;
      -webkit-user-select: all;  /* Chrome all / Safari all */
      -moz-user-select: all;     /* Firefox all */
      -ms-user-select: all;      /* IE 10+ */
      user-select: all;          /* Likely future */
    }
  }
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
