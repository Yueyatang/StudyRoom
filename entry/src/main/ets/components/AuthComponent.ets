import { AuthMode } from '../common/StudyRoomTypes';

@Component
export struct AuthComponent {
  @Prop authMode: AuthMode = 'login';
  @Prop account: string = '';
  @Prop password: string = '';
  @Prop nickname: string = '';
  @Prop confirmPassword: string = '';

  @State captchaInput: string = '';
  @State captchaCode: string = '';
  @State captchaError: string = '';

  private captchaSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private captchaContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.captchaSettings);
  private readonly captchaWidth: number = 186;
  private readonly captchaHeight: number = 64;

  onModeChange: (mode: AuthMode) => void = () => {};
  onAccountChange: (value: string) => void = () => {};
  onPasswordChange: (value: string) => void = () => {};
  onNicknameChange: (value: string) => void = () => {};
  onConfirmPasswordChange: (value: string) => void = () => {};
  onSubmit: () => void = () => {};

  aboutToAppear(): void {
    this.refreshCaptcha();
  }

  private getTitle(): string {
    return this.authMode === 'login' ? '欢迎回到沉浸式伴学' : '创建你的伴学账号';
  }

  private getDescription(): string {
    return this.authMode === 'login'
      ? '登录后可以继续你的专注记录、学习清单和陪伴成长进度。'
      : '注册后即可拥有自己的学习档案、陪伴角色和专注数据。';
  }

  private randomInt(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  private randomColor(alpha: number = 1): string {
    const red: number = this.randomInt(70, 245);
    const green: number = this.randomInt(70, 245);
    const blue: number = this.randomInt(70, 245);
    return `rgba(${red},${green},${blue},${alpha})`;
  }

  private createCaptchaCode(): string {
    const chars: string = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    let nextCode: string = '';
    for (let index = 0; index < 4; index++) {
      nextCode = `${nextCode}${chars[this.randomInt(0, chars.length - 1)]}`;
    }
    return nextCode;
  }

  private refreshCaptcha(): void {
    this.captchaCode = this.createCaptchaCode();
    this.captchaInput = '';
    this.captchaError = '';
    this.drawCaptcha();
  }

  private drawCaptcha(): void {
    const ctx: CanvasRenderingContext2D = this.captchaContext;
    ctx.clearRect(0, 0, this.captchaWidth, this.captchaHeight);

    const gradient: CanvasGradient = ctx.createLinearGradient(0, 0, this.captchaWidth, this.captchaHeight);
    gradient.addColorStop(0, 'rgba(255, 237, 185, 0.95)');
    gradient.addColorStop(1, 'rgba(183, 218, 255, 0.92)');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, this.captchaWidth, this.captchaHeight);

    for (let index = 0; index < 7; index++) {
      ctx.beginPath();
      ctx.strokeStyle = this.randomColor(0.38);
      ctx.lineWidth = this.randomInt(1, 2);
      ctx.moveTo(this.randomInt(0, this.captchaWidth), this.randomInt(0, this.captchaHeight));
      ctx.bezierCurveTo(
        this.randomInt(0, this.captchaWidth),
        this.randomInt(0, this.captchaHeight),
        this.randomInt(0, this.captchaWidth),
        this.randomInt(0, this.captchaHeight),
        this.randomInt(0, this.captchaWidth),
        this.randomInt(0, this.captchaHeight)
      );
      ctx.stroke();
    }

    for (let index = 0; index < 34; index++) {
      ctx.fillStyle = this.randomColor(0.46);
      ctx.beginPath();
      ctx.arc(
        this.randomInt(0, this.captchaWidth),
        this.randomInt(0, this.captchaHeight),
        this.randomInt(1, 2),
        0,
        Math.PI * 2
      );
      ctx.fill();
    }

    const code: string = this.captchaCode === '' ? 'ABCD' : this.captchaCode;
    for (let index = 0; index < code.length; index++) {
      ctx.save();
      const x: number = 24 + index * 43 + this.randomInt(-2, 2);
      const y: number = 55 + this.randomInt(-3, 3);
      const angle: number = (this.randomInt(-14, 14) * Math.PI) / 180;
      ctx.translate(x, y);
      ctx.rotate(angle);
      ctx.font = `bold ${this.randomInt(52, 58)}px serif`;
      ctx.fillStyle = this.randomColor(1);
      ctx.fillText(code[index], 0, 0);
      ctx.restore();
    }
  }

  private submitWithCaptcha(): void {
    const input: string = this.captchaInput.trim().toUpperCase();
    if (input === '') {
      this.captchaError = '请输入图形验证码';
      return;
    }
    if (input !== this.captchaCode) {
      this.captchaError = '图形验证码错误，请重新输入';
      this.refreshCaptcha();
      return;
    }
    this.captchaError = '';
    this.onSubmit();
  }

  build(): void {
    Column() {
      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 6 }) {
            Text(this.getTitle())
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .textAlign(TextAlign.Center)

            Text(this.getDescription())
              .fontSize(13)
              .fontColor('rgba(255,255,255,0.72)')
              .textAlign(TextAlign.Center)
              .lineHeight(20)
          }
          .width('100%')

          Row({ space: 8 }) {
            Button('登录')
              .layoutWeight(1)
              .height(38)
              .fontSize(14)
              .fontWeight(this.authMode === 'login' ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(this.authMode === 'login' ? '#182231' : '#E7EDF5')
              .backgroundColor(this.authMode === 'login' ? '#FFD878' : 'rgba(255,255,255,0.10)')
              .borderRadius(20)
              .onClick(() => {
                this.onModeChange('login');
                this.refreshCaptcha();
              })

            Button('注册')
              .layoutWeight(1)
              .height(38)
              .fontSize(14)
              .fontWeight(this.authMode === 'register' ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(this.authMode === 'register' ? '#182231' : '#E7EDF5')
              .backgroundColor(this.authMode === 'register' ? '#FFD878' : 'rgba(255,255,255,0.10)')
              .borderRadius(20)
              .onClick(() => {
                this.onModeChange('register');
                this.refreshCaptcha();
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

          Column({ space: 6 }) {
            Text('图形验证码')
              .fontSize(13)
              .fontColor('rgba(255,255,255,0.72)')
              .width('100%')
              .textAlign(TextAlign.Start)

            Row({ space: 8 }) {
              TextInput({ placeholder: '请输入验证码', text: this.captchaInput })
                .layoutWeight(1)
                .placeholderColor('rgba(255,255,255,0.32)')
                .fontSize(14)
                .fontColor('#FFFFFF')
                .type(InputType.Normal)
                .height(42)
                .backgroundColor('rgba(255,255,255,0.08)')
                .borderRadius(16)
                .padding({ left: 16, right: 16 })
                .onChange((nextValue: string) => {
                  this.captchaInput = nextValue;
                  this.captchaError = '';
                })

              Canvas(this.captchaContext)
                .width(this.captchaWidth)
                .height(this.captchaHeight)
                .borderRadius(12)
                .clip(true)
                .backgroundColor('rgba(255,255,255,0.12)')
                .onReady(() => {
                  this.drawCaptcha();
                })
                .onClick(() => {
                  this.refreshCaptcha();
                })
            }

            Text(this.captchaError === '' ? '点击验证码图片可刷新。' : this.captchaError)
              .fontSize(10)
              .fontColor(this.captchaError === '' ? 'rgba(255,255,255,0.40)' : '#FFB4A6')
              .width('100%')
              .textAlign(TextAlign.Start)
          }
          .width('100%')

          Button(this.authMode === 'login' ? '进入自习室' : '注册进入')
            .width('100%')
            .height(44)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#182231')
            .backgroundColor('#FFD878')
            .borderRadius(24)
            .padding({ left: 12, right: 12 })
            .margin({ top: 2, bottom: 4 })
            .onClick(() => {
              this.submitWithCaptcha();
            })
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('88%')
    .height('78%')
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
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
  ): void {
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
