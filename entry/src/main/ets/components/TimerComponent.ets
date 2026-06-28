import { TimerMode } from '../common/StudyRoomTypes';

@Component
export struct TimerComponent {
  @Prop timerDisplay: string = '25:00';
  @Prop currentMode: TimerMode = 'focus';
  @Prop isRunning: boolean = false;
  @Prop completedFocusSessions: number = 0;
  @Prop totalFocusSeconds: number = 0;
  // 新增：用于绘制进度条
  @Prop totalSeconds: number = 0;
  @Prop totalDuration: number = 1; // 避免除零

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
      return this.isRunning ? '保持节奏，先专注这一轮。' : '整理思绪，准备进入专注状态。';
    }
    if (this.currentMode === 'shortBreak') {
      return this.isRunning ? '短暂放松一下，给大脑留出缓冲。' : '短休息即将开始，记得活动肩颈。';
    }
    return this.isRunning ? '长休息进行中，慢慢恢复能量。' : '完成阶段冲刺后，给自己一次完整休息。';
  }

  getFocusDurationLabel(): string {
    return `${Math.floor(this.totalFocusSeconds / 60)} 分钟`;
  }

  // 计算进度 (0 ~ 1)
  private getProgress(): number {
    const duration = this.totalDuration > 0 ? this.totalDuration : 1;
    const remain = Math.max(0, Math.min(this.totalSeconds, duration));
    return remain / duration;
  }

  build() {
    Column() {
      // 标题 & 当前模式标签
      Row() {
        Column() {
          Text('番茄钟')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text(this.getModeHint())
            .fontSize(12)
            .fontColor('rgba(234,239,244,0.76)')
            .margin({ top: 6 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text(this.getModeLabel(this.currentMode))
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFE2A8')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('rgba(255,216,120,0.16)')
          .borderRadius(16)
      }
      .width('100%')
      .margin({ bottom: 14 })

      // 模式切换按钮
      Row() {
        ForEach(this.modes, (mode: TimerMode) => {
          Button(this.getModeLabel(mode))
            .fontSize(12)
            .fontWeight(this.currentMode === mode ? FontWeight.Medium : FontWeight.Regular)
            .fontColor(this.currentMode === mode ? '#1D2430' : '#F4F7FA')
            .height(38)
            .layoutWeight(1)
            .backgroundColor(this.currentMode === mode ? '#FFD878' : 'rgba(255,255,255,0.10)')
            .borderRadius(20)
            .onClick(() => {
              this.onSelectMode(mode);
            })
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // ----- 计时器圆环 + 数字（核心） -----
      Stack({ alignContent: Alignment.Center }) {
        // 背景圆环
        Circle()
          .width(200)
          .height(200)
          .stroke('rgba(255,255,255,0.12)')
          .strokeWidth(6)
          .fill('transparent')

        // 进度圆环（金色，从顶部开始旋转）
        Circle()
          .width(200)
          .height(200)
          .stroke('#FFD878')
          .strokeWidth(6)
          .fill('transparent')
          .strokeDashArray([Math.PI * 200, Math.PI * 200]) // 周长 ≈ 565.48
          .strokeDashOffset((1 - this.getProgress()) * Math.PI * 200)
          .rotate({ angle: -90 }) // 起点在12点钟方向

        // 计时数字
        Column() {
          Text('当前计时')
            .fontSize(12)
            .fontColor('rgba(237,242,248,0.72)')
            .margin({ bottom: 10 })

          Text(this.timerDisplay)
            .fontSize(54)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .fontFamily('monospace')
            .letterSpacing(4)
        }
        .width('100%')
        .padding({ top: 28, bottom: 28 })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 控制按钮
      Row() {
        Button(this.isRunning ? '进行中' : '开始专注')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#162030')
          .height(42)
          .layoutWeight(1.3)
          .backgroundColor('#F6D08C')
          .borderRadius(21)
          .onClick(() => {
            this.onStart();
          })

        Button('暂停')
          .fontSize(14)
          .fontColor('#F3F6FA')
          .height(42)
          .layoutWeight(1)
          .backgroundColor('rgba(255,255,255,0.12)')
          .borderRadius(21)
          .margin({ left: 10 })
          .onClick(() => {
            this.onPause();
          })

        Button('重置')
          .fontSize(14)
          .fontColor('#F3F6FA')
          .height(42)
          .layoutWeight(1)
          .backgroundColor('rgba(255,255,255,0.12)')
          .borderRadius(21)
          .margin({ left: 10 })
          .onClick(() => {
            this.onReset();
          })
      }
      .width('100%')

      // 时长微调
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
          .backgroundColor('rgba(255,255,255,0.10)')
          .borderRadius(17)
          .onClick(() => {
            this.onAdjustMinutes(-5);
          })

        Button('+5 分钟')
          .fontSize(12)
          .fontColor('#EAF0F6')
          .height(34)
          .padding({ left: 14, right: 14 })
          .backgroundColor('rgba(255,255,255,0.10)')
          .borderRadius(17)
          .margin({ left: 8 })
          .onClick(() => {
            this.onAdjustMinutes(5);
          })
      }
      .width('100%')
      .margin({ top: 14, bottom: 14 })

      // 统计卡片
      Row() {
        Column() {
          Text('完成轮次')
            .fontSize(11)
            .fontColor('rgba(225,231,237,0.68)')
          Text(`${this.completedFocusSessions}`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ top: 6 })
        }
        .layoutWeight(1.1)
        .alignItems(HorizontalAlign.Start)
        .padding(14)
        .backgroundColor('rgba(255,255,255,0.08)')
        .borderRadius(20)

        Column() {
          Text('累计专注')
            .fontSize(11)
            .fontColor('rgba(225,231,237,0.68)')
          Text(this.getFocusDurationLabel())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ top: 6 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding(14)
        .backgroundColor('rgba(255,255,255,0.08)')
        .borderRadius(20)
        .margin({ left: 10 })
      }
      .width('100%')
      .margin({ top: 2 })
    }
    .width('90%')
    .backgroundColor('rgba(22,28,38,0.64)')
    .borderRadius(30)
    .padding({ left: 18, right: 18, top: 18, bottom: 18 })
    .border({
      width: 1,
      color: 'rgba(255,255,255,0.08)'
    })
    .margin({ bottom: 18 })
  }
}