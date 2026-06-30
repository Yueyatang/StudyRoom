import { TimerMode } from '../common/StudyRoomTypes';

@Component
export struct TimerComponent {
  @Prop timerDisplay: string = '25:00';
  @Prop currentMode: TimerMode = 'focus';
  @Prop isRunning: boolean = false;
  @Prop completedFocusSessions: number = 0;
  @Prop totalFocusSeconds: number = 0;
  @Prop totalSeconds: number = 0;
  @Prop totalDuration: number = 1;
  @Prop accentColor: string = '#FFD878';

  onStart: () => void = () => {};
  onPause: () => void = () => {};
  onReset: () => void = () => {};
  onAdjustMinutes: (minutes: number) => void = () => {};
  onSelectMode: (mode: TimerMode) => void = () => {};

  private readonly modes: TimerMode[] = ['focus', 'shortBreak', 'longBreak'];

  private getModeLabel(mode: TimerMode): string {
    if (mode === 'focus') {
      return '专注';
    }
    if (mode === 'shortBreak') {
      return '短休息';
    }
    return '长休息';
  }

  private getModeHint(): string {
    if (this.currentMode === 'focus') {
      return this.isRunning ? '保持节奏，先把这一轮安静完成。' : '整理思绪，准备进入专注状态。';
    }
    if (this.currentMode === 'shortBreak') {
      return this.isRunning ? '小憩片刻，让大脑缓一缓。' : '短休息即将开始，记得活动一下肩颈。';
    }
    return this.isRunning ? '长休息进行中，慢慢恢复能量。' : '完成一段冲刺后，给自己一次完整休息。';
  }

  private getFocusDurationLabel(): string {
    return `${Math.floor(this.totalFocusSeconds / 60)} 分钟`;
  }

  private getProgress(): number {
    const duration = this.totalDuration > 0 ? this.totalDuration : 1;
    const remain = Math.max(0, Math.min(this.totalSeconds, duration));
    return remain / duration;
  }

  build() {
    Column() {
      Row() {
        Column({ space: 6 }) {
          Text('番茄钟')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text(this.getModeHint())
            .fontSize(12)
            .fontColor('rgba(234,239,244,0.76)')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(this.getModeLabel(this.currentMode))
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.accentColor)
          .opacity(0.9)
          .borderRadius(16)
      }
      .width('100%')
      .margin({ bottom: 14 })

      Row({ space: 10 }) {
        ForEach(this.modes, (mode: TimerMode) => {
          Button(this.getModeLabel(mode))
            .fontSize(12)
            .fontWeight(this.currentMode === mode ? FontWeight.Bold : FontWeight.Regular)
            .fontColor(this.currentMode === mode ? '#142031' : '#F4F7FA')
            .height(38)
            .layoutWeight(1)
            .backgroundColor(this.currentMode === mode ? this.accentColor : 'rgba(255,255,255,0.10)')
            .borderRadius(20)
            .onClick(() => {
              this.onSelectMode(mode);
            })
        })
      }
      .width('100%')
      .margin({ bottom: 18 })

      Stack({ alignContent: Alignment.Center }) {
        Circle()
          .width(214)
          .height(214)
          .fill('rgba(255,255,255,0.03)')
          .shadow({
            radius: 32,
            color: `${this.accentColor}33`,
            offsetX: 0,
            offsetY: 6
          })

        Circle()
          .width(214)
          .height(214)
          .stroke('rgba(255,255,255,0.10)')
          .strokeWidth(8)
          .fill('transparent')

        Circle()
          .width(214)
          .height(214)
          .stroke(this.accentColor)
          .strokeWidth(8)
          .fill('transparent')
          .strokeDashArray([Math.PI * 214, Math.PI * 214])
          .strokeDashOffset((1 - this.getProgress()) * Math.PI * 214)
          .rotate({ angle: -90 })

        Column({ space: 10 }) {
          Text(this.currentMode === 'focus' ? '当前专注' : this.getModeLabel(this.currentMode))
            .fontSize(12)
            .fontColor('rgba(237,242,248,0.72)')

          Text(this.timerDisplay)
            .fontSize(54)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .fontFamily('monospace')
            .letterSpacing(4)
        }
      }
      .width('100%')
      .margin({ bottom: 18 })

      Row({ space: 10 }) {
        Button(this.isRunning ? '继续进行' : '开始专注')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#162030')
          .height(44)
          .layoutWeight(1.3)
          .backgroundColor(this.accentColor)
          .borderRadius(22)
          .onClick(() => {
            this.onStart();
          })

        Button('暂停')
          .fontSize(14)
          .fontColor('#F3F6FA')
          .height(44)
          .layoutWeight(1)
          .backgroundColor('rgba(255,255,255,0.10)')
          .borderRadius(22)
          .onClick(() => {
            this.onPause();
          })

        Button('重置')
          .fontSize(14)
          .fontColor('#F3F6FA')
          .height(44)
          .layoutWeight(1)
          .backgroundColor('rgba(255,255,255,0.10)')
          .borderRadius(22)
          .onClick(() => {
            this.onReset();
          })
      }
      .width('100%')

      Row() {
        Text('时长微调')
          .fontSize(12)
          .fontColor('rgba(228,233,239,0.72)')

        Blank()

        Button('-5 分钟')
          .fontSize(12)
          .fontColor('#EAF0F6')
          .height(34)
          .padding({ left: 14, right: 14 })
          .backgroundColor('rgba(255,255,255,0.08)')
          .borderRadius(17)
          .onClick(() => {
            this.onAdjustMinutes(-5);
          })

        Button('+5 分钟')
          .fontSize(12)
          .fontColor('#EAF0F6')
          .height(34)
          .padding({ left: 14, right: 14 })
          .backgroundColor('rgba(255,255,255,0.08)')
          .borderRadius(17)
          .margin({ left: 8 })
          .onClick(() => {
            this.onAdjustMinutes(5);
          })
      }
      .width('100%')
      .margin({ top: 14, bottom: 16 })

      Row({ space: 10 }) {
        this.buildStatCard('完成轮次', `${this.completedFocusSessions}`, this.accentColor)
        this.buildStatCard('累计专注', this.getFocusDurationLabel(), this.accentColor)
      }
      .width('100%')
    }
    .width('90%')
    .backgroundColor('rgba(22,28,38,0.66)')
    .borderRadius(30)
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .border({
      width: 1,
      color: `${this.accentColor}33`
    })
    .shadow({
      radius: 24,
      color: `${this.accentColor}1F`,
      offsetX: 0,
      offsetY: 10
    })
    .margin({ bottom: 18 })
  }

  @Builder
  private buildStatCard(title: string, value: string, accentColor: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(11)
        .fontColor('rgba(225,231,237,0.68)')

      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .padding(14)
    .backgroundColor('rgba(255,255,255,0.06)')
    .border({
      width: 1,
      color: `${accentColor}22`
    })
    .borderRadius(20)
  }
}
