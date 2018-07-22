<template lang="pug">
  #project
    .info(v-if="project")
      h1 {{project.name}}

      <div class="md-layout md-gutter">
        <div class="md-layout-item md-size-40">
          .emails
            .item(v-for="email in emails" v-on:click="show_email(email)")
              | {{email.subject}}

        </div>
        <div class="md-layout-item md-size-60">
          .email(v-if="email")
            .subject
              |{{email.subject}}
            .from
              |{{email.from.email}}
            .to
              .email(v-for="to in email.to")
                |{{to.email}}
            <iframe :src="iframe_src(email.secret_id)">
            </iframe>


          .credentials(v-else)
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
    emails: [],
    email: null
  }),

  methods: {
    show_email(email){
      this.email = email
    },

    iframe_src(id){
      return "/email/" + id
    }

  },
  computed: {
    project(){
       return this.$store.getters.currentProject(this.$route.params.project_id)[0]
    }
  },

  created(){
    this.$http.get('/api/emails', {params: {project_id: this.$route.params.project_id}}).then(response => {
      //this.$store.dispatch('SET_PROJECT_EMAIL', response.body.data)
      //console.log(this.$store.getters.currentProjectEmails)
      this.emails = response.body.data
    }, error => {
      // error callback
      this.errors = error.body.errors
    })
  }


}
</script>

<style lang="scss">
#project{
  .emails{
    background: #fff;
    padding: 5px;

    .item{
      color: #0976ef;
      cursor: pointer;
      margin: 0 0 5px 0;
    }
  }
  .credentials{

    span.content{
      background: #f7f7f7;
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
