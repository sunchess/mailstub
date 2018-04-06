<template lang="pug">
  #login
    .form.md-card.md-layout-item.md-size-25.md-small-size-100
      <md-field md-clearable>
        <label>Email</label>
        <md-input v-model="form.email"></md-input>
      </md-field>

      <md-field>
        <label>Password</label>
        <md-input v-model="form.password" type="password"></md-input>
      </md-field>
      <md-card-actions>
        <md-button type="submit" class="md-primary" :disabled="sending" v-on:click="saveUser">Create user</md-button>
      </md-card-actions>
</template>

<script>
export default {
  name: 'login',
  data: () => ({
    form: {
      email: null,
      password: null,
    },
    userSaved: false,
    sending: false
  }),
  methods: {
    saveUser () {
       this.sending = true
    }
  }
}
</script>

<style lang="scss">
  #login{
    .form{
      width: 300px;
      margin: 0 auto;
      padding: 10px
    }
  }
</style>
