import { AuthMode } from '../common/StudyRoomTypes';

@Component
export struct AuthComponent {
  @Prop authMode: AuthMode = 'login';
  @Prop account: string = '';
  @Prop password: string = '';
  @Prop nickname: string = '';
  @Prop confirmPassword: string = '';

  onModeChange: (mode: AuthMode) => void = () => {};
  onAccountChange: (value: string) => void = () => {};
  onPasswordChange: (value: string) => void = () => {};
  onNicknameChange: (value: string) => void = () => {};
  onConfirmPasswordChange: (value: string) => void = () => {};
  onSubmit: () => void = () => {};

  private getTitle(): string {
    return this.authMode === 'login' ? '欢迎回到沉浸式伴学' : '创建你的伴学账户';
  }

  private getDescription(): string {
    return this.authMode === 'login'
      ? '登录后可以同步保存学习清单、番茄统计和陪伴记录。'
      : '注册后就能拥有自己的专属陪伴角色和学习档案。';
  }

  build() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text(this.getTitle())
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)

        Text(this.getDescription())
          .fontSize(13)
          .fontColor('rgba(255,255,255,0.72)')
          .textAlign(TextAlign.Center)
          .lineHeight(22)
      }
      .width('100%')

      Row({ space: 10 }) {
        Button('登录')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .fontWeight(this.authMode === 'login' ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(this.authMode === 'login' ? '#182231' : '#E7EDF5')
          .backgroundColor(this.authMode === 'login' ? '#FFD878' : 'rgba(255,255,255,0.10)')
          .borderRadius(20)
          .onClick(() => {
            this.onModeChange('login');
          })

        Button('注册')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .fontWeight(this.authMode === 'register' ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(this.authMode === 'register' ? '#182231' : '#E7EDF5')
          .backgroundColor(this.authMode === 'register' ? '#FFD878' : 'rgba(255,255,255,0.10)')
          .borderRadius(20)
          .onClick(() => {
            this.onModeChange('register');
          })
      }
      .width('100%')

      if (this.authMode === 'register') {
        this.buildInput('昵称', '输入你的学习昵称', this.nickname, false, (value: string) => {
          this.onNicknameChange(value);
        })
      }

      this.buildInput('账号', '请输入账号', this.account, false, (value: string) => {
        this.onAccountChange(value);
      })

      this.buildInput('密码', '请输入密码', this.password, true, (value: string) => {
        this.onPasswordChange(value);
      })

      if (this.authMode === 'register') {
        this.buildInput('确认密码', '再次输入密码', this.confirmPassword, true, (value: string) => {
          this.onConfirmPasswordChange(value);
        })
      }

      Button(this.authMode === 'login' ? '进入自习室' : '注册并进入')
        .width('100%')
        .height(48)
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#182231')
        .backgroundColor('#FFD878')
        .borderRadius(24)
        .margin({ top: 6 })
        .onClick(() => {
          this.onSubmit();
        })

      Column({ space: 6 }) {
        Text('默认实现的是本地账户体系')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.48)')

        Text('适合演示“学习数据持久化”和“个人档案管理”的完整流程。')
          .fontSize(11)
          .fontColor('rgba(255,255,255,0.38)')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .margin({ top: 2 })
    }
    .width('88%')
    .padding({ left: 22, right: 22, top: 26, bottom: 26 })
    .backgroundColor('rgba(18,24,34,0.76)')
    .borderRadius(30)
    .border({
      width: 1,
      color: 'rgba(255,255,255,0.08)'
    })
  }

  @Builder
  private buildInput(
    label: string,
    placeholder: string,
    value: string,
    isPassword: boolean,
    onChangeValue: (value: string) => void
  ) {
    Column({ space: 8 }) {
      Text(label)
        .fontSize(13)
        .fontColor('rgba(255,255,255,0.72)')
        .width('100%')
        .textAlign(TextAlign.Start)

      TextInput({ placeholder: placeholder, text: value })
        .placeholderColor('rgba(255,255,255,0.32)')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .type(isPassword ? InputType.Password : InputType.Normal)
        .height(46)
        .width('100%')
        .backgroundColor('rgba(255,255,255,0.08)')
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .onChange((nextValue: string) => {
          onChangeValue(nextValue);
        })
    }
    .width('100%')
  }
}
