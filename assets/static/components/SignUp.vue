<template lang="pug">
  #sign_up
    .form.md-card.md-layout-item.md-size-25.md-small-size-100
      <md-field md-clearable>
        <label>Email</label>
        <md-input v-model="form.email"></md-input>
      </md-field>

      <md-field>
        <label>Password</label>
        <md-input v-model="form.password" type="password"></md-input>
      </md-field>

      <md-field>
        <label>Retype Password</label>
        <md-input v-model="form.re_password" type="password"></md-input>
      </md-field>

      <md-card-actions>
        <md-button type="submit" class="md-primary md-raised" :disabled="sending" v-on:click="saveUser">Send</md-button>
      </md-card-actions>
</template>

<script>
export default {
  name: 'sign_up',
  data: () => ({
    form: {
      email: null,
      password: null,
      re_password: null,
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
  #sign_up{
    .form{
      width: 300px;
      margin: 0 auto;
      padding: 10px
    }
  }
</style>
