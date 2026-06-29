@Component
export struct ImmersionVideoComponent {
  @Watch('onRunningChange') @Prop isRunning: boolean = false;
  @Prop timerDisplay: string = '25:00';
  @Prop currentSceneName: string = '';
  @Prop suggestion: string = '';
  @Prop activeTaskText: string = '';
  @Prop activeTaskProgress: string = '';

  @State videoMuted: boolean = false;
  @State videoPrepared: boolean = false;
  @State videoPlaying: boolean = false;

  private controller: VideoController = new VideoController();

  aboutToDisappear(): void {
    this.videoPrepared = false;
    this.videoPlaying = false;
    this.controller.pause();
  }

  private onRunningChange(): void {
    if (!this.videoPrepared) {
      return;
    }
    if (this.isRunning) {
      this.controller.start();
      this.videoPlaying = true;
    } else {
      this.controller.pause();
      this.videoPlaying = false;
    }
  }

  private getTaskLabel(): string {
    if (this.activeTaskText === '') {
      return '暂未选择专注任务';
    }
    return this.activeTaskText;
  }

  private getProgressLabel(): string {
    if (this.activeTaskProgress === '') {
      return '可以先去学习清单选择一个任务';
    }
    return this.activeTaskProgress;
  }

  build(): void {
    Stack() {
      Video({
        src: $rawfile('study.mp4'),
        controller: this.controller
      })
        .width('100%')
        .height('100%')
        .controls(false)
        .autoPlay(false)
        .loop(true)
        .muted(this.videoMuted)
        .objectFit(ImageFit.Cover)
        .onPrepared(() => {
          this.videoPrepared = true;
          if (this.isRunning) {
            this.controller.start();
            this.videoPlaying = true;
          } else {
            this.videoPlaying = false;
          }
        })

      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [
            ['rgba(8,10,18,0.10)', 0],
            ['rgba(8,10,18,0.24)', 0.35],
            ['rgba(8,10,18,0.78)', 1]
          ]
        })

      Column({ space: 16 }) {
        Column({ space: 6 }) {
          Text(this.timerDisplay)
            .fontSize(54)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .fontFamily('monospace')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ top: 12, bottom: 12 })

        Blank()

        Column({ space: 14 }) {
          Column({ space: 8 }) {
            Text('当前任务')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.60)')
              .width('100%')
              .textAlign(TextAlign.Start)

            Text(this.getTaskLabel())
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .width('100%')
              .textAlign(TextAlign.Start)
              .maxLines(2)

            Text(this.getProgressLabel())
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.72)')
              .width('100%')
              .textAlign(TextAlign.Start)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          .backgroundColor('rgba(8,12,20,0.42)')
          .borderRadius(24)

          Row({ space: 10 }) {
            Button(this.videoMuted ? '打开视频声音' : '关闭视频声音')
              .layoutWeight(1)
              .height(42)
              .fontSize(13)
              .fontColor('#F5F7FA')
              .backgroundColor('rgba(255,255,255,0.12)')
              .borderRadius(21)
              .onClick(() => {
                this.videoMuted = !this.videoMuted;
              })

            Button(this.videoPlaying ? '暂停画面' : '继续播放')
              .layoutWeight(1)
              .height(42)
              .fontSize(13)
              .fontColor('#1B2431')
              .backgroundColor('#FFD878')
              .borderRadius(21)
              .onClick(() => {
                if (!this.videoPrepared) {
                  return;
                }
                if (this.videoPlaying) {
                  this.controller.pause();
                  this.videoPlaying = false;
                } else {
                  this.controller.start();
                  this.videoPlaying = true;
                }
              })
          }
          .width('100%')
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .padding({ left: 20, right: 20, top: 28, bottom: 22 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
  }
}
