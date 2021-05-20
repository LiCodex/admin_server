<template>
  <div class="createPost-container">
    <el-form ref="form" :model="form" label-width="180px">
      <el-form-item label="游戏规则设置">
        <el-input type="textarea" v-model="form.text"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="onSubmit">立即设置</el-button>
      </el-form-item>
    </el-form>
  </div>
</template>

<script>
  import { setrule, getrule } from '@/api/setting'
  export default {
    data() {
      return {
        listLoading: true,
        form: {
          text: '',
        }
      }
    },
    created() {
      this.getList()
    },
    methods: {
      getList() {
        this.listLoading = true
        getrule().then(response => {
          console.log(JSON.stringify(response))
          this.form.text = response.data
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      },
      handleModifyStatus() {
        this.$message({
          message: '设置成功',
          type: 'success'
        })
      },
      onSubmit() {
        this.listLoading = true
        setrule(this.form).then(response => {
          this.handleModifyStatus()
          this.listLoading = false
        }).catch(() => {
          this.listLoading = false
        })
      }
    }
  }
</script>
