import { TimerMode } from '../common/StudyRoomTypes';


@Component
export struct TimerComponent {
  @Prop timerDisplay: string = '25:00';
  @Prop currentMode: TimerMode = 'focus';
  @Prop isRunning: boolean = false;
  @Prop completedFocusSessions: number = 0;
  @Prop totalFocusMinutes: number = 0;
  onStart: () => void = () => {};
  onPause: () => void = () => {};
  onReset: () => void = () => {};
  onAdjustMinutes: (minutes: number) => void = () => {};
  onSelectMode: (mode: TimerMode) => void = () => {};

  private readonly modes: TimerMode[] = ['focus', 'shortBreak', 'longBreak'];

  getModeLabel(mode: TimerMode): string {
    if (mode === 'focus') {
      return '专注';
    }
    if (mode === 'shortBreak') {
      return '短休息';
    }
    return '长休息';
  }

  getModeHint(): string {
    if (this.currentMode === 'focus') {
      return this.isRunning ? '保持专注中' : '准备开始专注';
    }
    if (this.currentMode === 'shortBreak') {
      return this.isRunning ? '短暂放松中' : '短休息准备';
    }
    return this.isRunning ? '长休息中' : '长休息准备';
  }

  build() {
    Column() {
      Row() {
        ForEach(this.modes, (mode: TimerMode) => {
          Button(this.getModeLabel(mode))
            .fontSize(12)
            .fontColor(this.currentMode === mode ? '#FFD878' : '#FFFFFF')
            .height(34)
            .layoutWeight(1)
            .backgroundColor(this.currentMode === mode ? 'rgba(255,216,120,0.25)' : 'rgba(255,255,255,0.10)')
            .borderRadius(18)
            .onClick(() => {
              this.onSelectMode(mode);
            })
        })
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text(this.getModeHint())
        .fontSize(13)
        .fontColor('#DADADA')
        .margin({ bottom: 8 })

      Text(this.timerDisplay)
        .fontSize(56)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .fontFamily('monospace')
        .letterSpacing(6)
        .margin({ top: 12, bottom: 12 })

      Row() {
        Button(this.isRunning ? '运行中' : '开始')
          .fontSize(14)
          .height(38)
          .padding({ left: 20, right: 20 })
          .backgroundColor('rgba(100,120,200,0.8)')
          .borderRadius(38)
          .onClick(() => {
            this.onStart();
          })

        Button('暂停')
          .fontSize(14)
          .height(38)
          .padding({ left: 20, right: 20 })
          .backgroundColor('rgba(60,60,80,0.8)')
          .borderRadius(38)
          .margin({ left: 10 })
          .onClick(() => {
            this.onPause();
          })

        Button('重置')
          .fontSize(14)
          .height(38)
          .padding({ left: 20, right: 20 })
          .backgroundColor('rgba(60,60,80,0.8)')
          .borderRadius(38)
          .margin({ left: 10 })
          .onClick(() => {
            this.onReset();
          })
      }

      Row() {
        Button('-5')
          .fontSize(12)
          .height(34)
          .backgroundColor('rgba(45,50,65,0.8)')
          .borderRadius(34)
          .layoutWeight(1)
          .onClick(() => {
            this.onAdjustMinutes(-5);
          })

        Button('+5')
          .fontSize(12)
          .height(34)
          .backgroundColor('rgba(45,50,65,0.8)')
          .borderRadius(34)
          .layoutWeight(1)
          .margin({ left: 12 })
          .onClick(() => {
            this.onAdjustMinutes(5);
          })
      }
      .width('100%')
      .margin({ top: 10, bottom: 10 })

      Row() {
        Column() {
          Text('专注轮次')
            .fontSize(11)
            .fontColor('#B8B8B8')
          Text(`${this.completedFocusSessions}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Column() {
          Text('今日专注')
            .fontSize(11)
            .fontColor('#B8B8B8')
          Text(`${this.totalFocusMinutes} min`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .margin({ top: 4 })
    }
    .width('90%')
    .backgroundColor('rgba(30,34,48,0.6)')
    .borderRadius(28)
    .padding(16)
    .margin({ bottom: 16 })
  }
}
