<template lang="pug">
  #form_project
    h1 New Project

    .form.md-card.md-layout-item.md-size-25.md-small-size-100
      <span class="md-error " v-if="errors">{{errors.join(", ")}}</span>
      <md-field md-clearable>
        <label>Name</label>
        <md-input v-model="form.name"></md-input>
      </md-field>

      <md-card-actions>
        <md-button type="submit" class="md-primary md-raised" :disabled="sending" v-on:click="saveProject">Save</md-button>
      </md-card-actions>

</template>

<script>
export default {
  name: 'form_project',
  data: () => ({
    form: {},
    project: null,
    sending: null,
    errors: null
  }),
  methods: {
    saveProject() {
       this.sending = true
       this.$http.post('/api/projects', {project: this.form}).then(response => {
         this.projectSaved = true
         this.$router.push({name: 'projects'})
       }, error => {
         // error callback
         this.sending = false
         this.errors = error.body.errors
       })
    }
  }
}
</script>

<style lang="scss">

  #form_project{
    .form{
      width: 300px;
      margin: 0 auto;
      padding: 10px
    }
  }
</style>
