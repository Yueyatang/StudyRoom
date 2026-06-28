import { UserProfile } from '../common/StudyRoomTypes';

@Component
export struct ProfileComponent {
  @Prop profile: UserProfile = {
    nickname: '学习搭子',
    account: '',
    signature: '',
    targetTomatoes: 6
  };
  @Prop continuousDays: number = 0;
  @Prop totalTomatoCount: number = 0;
  @Prop todayTomatoCount: number = 0;
  @Prop totalFocusMinutes: number = 0;
  @Prop statsVersion: number = 0;

  onNicknameChange: (value: string) => void = () => {};
  onSignatureChange: (value: string) => void = () => {};
  onTargetChange: (value: string) => void = () => {};
  onSave: () => void = () => {};
  onLogout: () => void = () => {};

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text(`${this.statsVersion}`)
          .width(0)
          .height(0)
          .opacity(0)

        Column({ space: 10 }) {
          Stack({ alignContent: Alignment.Center }) {
            Circle()
              .width(82)
              .height(82)
              .fill('rgba(255,216,120,0.18)')

            Text(this.profile.nickname.length > 0 ? this.profile.nickname.substring(0, 1) : '学')
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFD878')
          }

          Text(this.profile.nickname)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text(`账号：${this.profile.account}`)
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.54)')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 24 })

        Row({ space: 10 }) {
          this.buildStatCard('连续学习', `${this.continuousDays} 天`)
          this.buildStatCard('今日番茄', `${this.todayTomatoCount} 个`)
          this.buildStatCard('累计专注', `${this.totalFocusMinutes} 分钟`)
        }
        .width('100%')

        this.buildField('昵称', '输入昵称', this.profile.nickname, (value: string) => {
          this.onNicknameChange(value);
        })

        this.buildField('个性签名', '写一句鼓励自己的话', this.profile.signature, (value: string) => {
          this.onSignatureChange(value);
        })

        this.buildField('每日目标番茄数', '例如 6', `${this.profile.targetTomatoes}`, (value: string) => {
          this.onTargetChange(value);
        })

        Column({ space: 10 }) {
          Text('学习档案')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width('100%')
            .textAlign(TextAlign.Start)

          this.buildRecordRow('累计完成番茄', `${this.totalTomatoCount} 个`)
          this.buildRecordRow('当前陪伴等级', this.totalTomatoCount >= 80 ? '沉浸搭子' : this.totalTomatoCount >= 30 ? '默契同桌' : '熟悉陪伴')
          this.buildRecordRow('目标完成度', this.profile.targetTomatoes > 0 ? `${Math.min(100, Math.round(this.todayTomatoCount / this.profile.targetTomatoes * 100))}%` : '0%')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor('rgba(255,255,255,0.08)')
        .borderRadius(24)

        Row({ space: 10 }) {
          Button('保存资料')
            .layoutWeight(1)
            .height(46)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A2432')
            .backgroundColor('#FFD878')
            .borderRadius(23)
            .onClick(() => {
              this.onSave();
            })

          Button('退出登录')
            .layoutWeight(1)
            .height(46)
            .fontSize(14)
            .fontColor('#F3F6FA')
            .backgroundColor('rgba(255,255,255,0.10)')
            .borderRadius(23)
            .onClick(() => {
              this.onLogout();
            })
        }
        .width('100%')
        .margin({ bottom: 28 })
      }
      .width('90%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildStatCard(title: string, value: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(12)
        .fontColor('rgba(255,255,255,0.58)')

      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 14 })
    .backgroundColor('rgba(255,255,255,0.08)')
    .borderRadius(22)
  }

  @Builder
  private buildField(title: string, placeholder: string, value: string, onChangeValue: (value: string) => void) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontColor('rgba(255,255,255,0.7)')
        .width('100%')
        .textAlign(TextAlign.Start)

      TextInput({ placeholder: placeholder, text: value })
        .placeholderColor('rgba(255,255,255,0.30)')
        .fontSize(14)
        .fontColor('#FFFFFF')
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

  @Builder
  private buildRecordRow(title: string, value: string) {
    Row() {
      Text(title)
        .fontSize(13)
        .fontColor('rgba(255,255,255,0.62)')

      Blank()

      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 })
  }
}
