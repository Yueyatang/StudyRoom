import { CompanionProgress, DailyTomatoRecord, UserProfile } from '../common/StudyRoomTypes';

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
  @Prop accentColor: string = '#FFD878';
  @Prop contributionDays: DailyTomatoRecord[] = [];
  @Prop companionProgress: CompanionProgress = {
    level: 1,
    totalAffinity: 0,
    currentLevelAffinity: 0,
    nextLevelAffinity: 100
  };
  onNicknameChange: (value: string) => void = () => {};
  onSignatureChange: (value: string) => void = () => {};
  onTargetChange: (value: string) => void = () => {};
  onSave: () => void = () => {};
  onLogout: () => void = () => {};
  onGoCompanion: () => void = () => {};

  private getAvatarText(): string {
    if (this.profile.nickname.length > 0) {
      return this.profile.nickname.substring(0, 1);
    }
    return '学';
  }

  private getWeeklyRecords(): DailyTomatoRecord[] {
    if (this.contributionDays.length <= 7) {
      return this.contributionDays;
    }
    const list: DailyTomatoRecord[] = [];
    for (let index = this.contributionDays.length - 7; index < this.contributionDays.length; index++) {
      list.push(this.contributionDays[index]);
    }
    return list;
  }

  private getWeeklyMax(): number {
    let max = 1;
    this.getWeeklyRecords().forEach((item: DailyTomatoRecord) => {
      if (item.count > max) {
        max = item.count;
      }
    });
    return max;
  }

  private getDayLabel(dateText: string): string {
    if (dateText.length >= 10) {
      return dateText.substring(5).replace('-', '/');
    }
    return dateText;
  }

  private getCompanionProgressRatio(): number {
    if (this.companionProgress.nextLevelAffinity <= 0) {
      return 1;
    }
    return Math.min(1, this.companionProgress.currentLevelAffinity / this.companionProgress.nextLevelAffinity);
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text(`${this.statsVersion}`)
          .width(0)
          .height(0)
          .opacity(0)

        Column({ space: 14 }) {
          Row({ space: 14 }) {
            Stack({ alignContent: Alignment.Center }) {
              Circle()
                .width(96)
                .height(96)
                .fill(`${this.accentColor}22`)
                .shadow({
                  radius: 24,
                  color: `${this.accentColor}2A`,
                  offsetX: 0,
                  offsetY: 6
                })

              Text(this.getAvatarText())
                .fontSize(34)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }

            Column({ space: 8 }) {
              Text(this.profile.nickname)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width('100%')
                .textAlign(TextAlign.Start)

              Text(`账号：${this.profile.account}`)
                .fontSize(12)
                .fontColor('rgba(255,255,255,0.54)')
                .width('100%')
                .textAlign(TextAlign.Start)

              Text(this.profile.signature)
                .fontSize(13)
                .fontColor('rgba(255,255,255,0.74)')
                .width('100%')
                .textAlign(TextAlign.Start)
                .lineHeight(20)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')

          Row({ space: 10 }) {
            Button('保存资料')
              .layoutWeight(1)
              .height(42)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor('#152131')
              .backgroundColor(this.accentColor)
              .borderRadius(21)
              .onClick(() => {
                this.onSave();
              })

            Button('退出登录')
              .layoutWeight(1)
              .height(42)
              .fontSize(14)
              .fontColor('#F3F6FA')
              .backgroundColor('rgba(255,255,255,0.10)')
              .borderRadius(21)
              .onClick(() => {
                this.onLogout();
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 18, right: 18, top: 22, bottom: 22 })
        .backgroundColor('rgba(255,255,255,0.08)')
        .border({
          width: 1,
          color: `${this.accentColor}22`
        })
        .borderRadius(30)
        .margin({ top: 24 })

        Row({ space: 10 }) {
          this.buildAchievementCard('连续天数', `${this.continuousDays} 天`, '稳稳在线')
          this.buildAchievementCard('累计番茄', `${this.totalTomatoCount} 个`, '专注沉淀')
          this.buildAchievementCard('累计专注', `${this.totalFocusMinutes} 分钟`, '时间投资')
        }
        .width('100%')

        Column({ space: 12 }) {
          Row() {
            Text('本周学习趋势')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')

            Blank()

            Text('最近 7 天')
              .fontSize(11)
              .fontColor('rgba(255,255,255,0.54)')
          }
          .width('100%')

          Row({ space: 8 }) {
            ForEach(this.getWeeklyRecords(), (item: DailyTomatoRecord) => {
              Column({ space: 8 }) {
                Blank()

                Column()
                  .width('100%')
                  .height(`${Math.max(18, item.count / this.getWeeklyMax() * 96)}vp`)
                  .backgroundColor(item.count > 0 ? this.accentColor : 'rgba(255,255,255,0.08)')
                  .opacity(item.count > 0 ? 0.92 : 0.5)
                  .borderRadius(14)

                Text(`${item.count}`)
                  .fontSize(10)
                  .fontColor('rgba(255,255,255,0.72)')

                Text(this.getDayLabel(item.date))
                  .fontSize(9)
                  .fontColor('rgba(255,255,255,0.42)')
            }
            .layoutWeight(1)
            .height(160)
            .justifyContent(FlexAlign.End)
            .alignItems(HorizontalAlign.Center)
            }, (item: DailyTomatoRecord) => item.date)
          }
          .width('100%')
          .height(160)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor('rgba(255,255,255,0.08)')
        .borderRadius(24)

        Column({ space: 12 }) {
          Row() {
            Text('陪伴关系进度')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')

            Blank()

            Text(`Lv.${this.companionProgress.level}`)
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#152131')
              .padding({ left: 10, right: 10, top: 5, bottom: 5 })
              .backgroundColor(this.accentColor)
              .borderRadius(14)
          }
          .width('100%')

          Text(`当前默契值 ${this.companionProgress.currentLevelAffinity}/${this.companionProgress.nextLevelAffinity}`)
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.68)')
            .width('100%')
            .textAlign(TextAlign.Start)

          Stack({ alignContent: Alignment.Start }) {
            Row()
              .width('100%')
              .height(8)
              .backgroundColor('rgba(255,255,255,0.10)')
              .borderRadius(4)

            Row()
              .width(`${this.getCompanionProgressRatio() * 100}%`)
              .height(8)
              .backgroundColor(this.accentColor)
              .borderRadius(4)
          }
          .width('100%')

          Button('前往陪伴页互动')
            .width('100%')
            .height(42)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#152131')
            .backgroundColor(this.accentColor)
            .borderRadius(21)
            .onClick(() => {
              this.onGoCompanion();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor('rgba(255,255,255,0.08)')
        .borderRadius(24)

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
          this.buildRecordRow('今日番茄完成率', this.profile.targetTomatoes > 0 ? `${Math.min(100, Math.round(this.todayTomatoCount / this.profile.targetTomatoes * 100))}%` : '0%')
          this.buildRecordRow('陪伴总默契值', `${this.companionProgress.totalAffinity}`)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor('rgba(255,255,255,0.08)')
        .borderRadius(24)
        .margin({ bottom: 28 })
      }
      .width('90%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildAchievementCard(title: string, value: string, hint: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(12)
        .fontColor('rgba(255,255,255,0.58)')
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(hint)
        .fontSize(11)
        .fontColor(this.accentColor)
        .width('100%')
        .textAlign(TextAlign.Start)
    }
    .layoutWeight(1)
    .padding({ left: 14, right: 14, top: 16, bottom: 16 })
    .backgroundColor('rgba(255,255,255,0.08)')
    .border({
      width: 1,
      color: `${this.accentColor}22`
    })
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
