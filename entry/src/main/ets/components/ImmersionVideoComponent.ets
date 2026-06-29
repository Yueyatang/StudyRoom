@Component
export struct ImmersionVideoComponent {
  @Watch('onRunningChange') @Prop isRunning: boolean = false;
  @Prop timerDisplay: string = '25:00';
  @Prop currentSceneName: string = '';
  @Prop suggestion: string = '';
  @Prop activeTaskText: string = '';
  @Prop activeTaskProgress: string = '';
  @Prop currentVideoName: string = 'nearwindows_study.mp4';
  @Prop currentVideoIndex: number = 0;
  @Prop videoList: string[] = [];

  @State videoMuted: boolean = false;
  @State videoPrepared: boolean = false;
  @State videoPlaying: boolean = false;

  private controller: VideoController = new VideoController();
  private videoTabScroller: Scroller = new Scroller();
  onVideoChange: (index: number) => void = () => {};

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
      return '还没有选择专注任务';
    }
    return this.activeTaskText;
  }

  private getProgressLabel(): string {
    if (this.activeTaskProgress === '') {
      return '可以先去学习清单选择一个任务';
    }
    return this.activeTaskProgress;
  }

  private getVideoDisplayName(fileName: string): string {
    if (fileName === 'nearwindows_study.mp4') {
      return '窗边陪学';
    }
    if (fileName === 'rain_study.mp4') {
      return '雨天陪学';
    }
    if (fileName === 'only_study.mp4') {
      return '纯净书桌';
    }
    return '基础陪学';
  }

  build(): void {
    Stack() {
      Video({
        src: $rawfile(this.currentVideoName),
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
        Row() {
          Column({ space: 2 }) {
            Text('当前倒计时')
              .fontSize(10)
              .fontColor('rgba(255,255,255,0.54)')

            Text(this.timerDisplay)
              .fontSize(34)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .fontFamily('monospace')
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 14, right: 14, top: 10, bottom: 10 })
          .backgroundColor('rgba(8,12,20,0.22)')
          .borderRadius(18)

          Blank()
        }
        .width('100%')
        .padding({ top: 6, bottom: 6 })

        Blank()

        Column({ space: 8 }) {
          Scroll(this.videoTabScroller) {
            Row({ space: 8 }) {
              ForEach(this.videoList, (item: string, index: number) => {
                Button(this.getVideoDisplayName(item))
                  .fontSize(11)
                  .fontColor(this.currentVideoIndex === index ? '#1B2431' : '#F5F7FA')
                  .height(32)
                  .padding({ left: 14, right: 14 })
                  .backgroundColor(this.currentVideoIndex === index ? '#FFD878' : 'rgba(255,255,255,0.12)')
                  .borderRadius(16)
                  .onClick(() => {
                    this.onVideoChange(index);
                    this.videoPrepared = false;
                    this.videoPlaying = false;
                  })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          Row() {
            Column({ space: 4 }) {
              Text(this.getTaskLabel())
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width('100%')
                .textAlign(TextAlign.Start)
                .maxLines(1)

              Text(this.getProgressLabel())
                .fontSize(11)
                .fontColor('rgba(255,255,255,0.68)')
                .width('100%')
                .textAlign(TextAlign.Start)
                .maxLines(1)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 10, bottom: 10 })
          .backgroundColor('rgba(8,12,20,0.28)')
          .borderRadius(16)

          Row({ space: 8 }) {
            Button(this.videoMuted ? '开声' : '静音')
              .height(36)
              .fontSize(12)
              .fontColor('#F5F7FA')
              .padding({ left: 16, right: 16 })
              .backgroundColor('rgba(255,255,255,0.12)')
              .borderRadius(18)
              .onClick(() => {
                this.videoMuted = !this.videoMuted;
              })

            Button(this.videoPlaying ? '暂停' : '播放')
              .height(36)
              .fontSize(12)
              .fontColor('#1B2431')
              .padding({ left: 18, right: 18 })
              .backgroundColor('#FFD878')
              .borderRadius(18)
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

            Blank()
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
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
