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
  @Prop accentColor: string = '#FFD878';

  @State videoMuted: boolean = false;
  @State videoPrepared: boolean = false;
  @State videoPlaying: boolean = false;
  @State minimalMode: boolean = false;
  @State pressedVideoIndex: number = -1;

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
      return '还没有选择当前专注任务';
    }
    return this.activeTaskText;
  }

  private getProgressLabel(): string {
    if (this.activeTaskProgress === '') {
      return '可以先去学习清单里选一个任务再开始';
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
    return '沉浸陪学';
  }

  private switchVideoByIndex(index: number): void {
    animateTo({ duration: 110, curve: Curve.EaseOut }, () => {
      this.pressedVideoIndex = index;
    });
    this.onVideoChange(index);
    this.videoPrepared = false;
    this.videoPlaying = false;
    setTimeout(() => {
      animateTo({ duration: 180, curve: Curve.EaseOut }, () => {
        this.pressedVideoIndex = -1;
      });
    }, 120);
  }

  @Builder
  private buildVideoDots(): void {
    Row({ space: 10 }) {
      ForEach(this.videoList, (item: string, index: number) => {
        Row()
          .width(this.currentVideoIndex === index ? 28 : 12)
          .height(12)
          .borderRadius(10)
          .backgroundColor(this.currentVideoIndex === index ? '#FFD878' : 'rgba(255,255,255,0.38)')
          .border({
            width: this.currentVideoIndex === index ? 0 : 1,
            color: 'rgba(255,255,255,0.16)'
          })
          .opacity(this.currentVideoIndex === index ? 1 : 0.9)
          .scale({
            x: this.pressedVideoIndex === index ? 0.9 : (this.currentVideoIndex === index ? 1.06 : 1),
            y: this.pressedVideoIndex === index ? 0.9 : 1
          })
          .shadow(this.currentVideoIndex === index ? {
            radius: 10,
            color: 'rgba(255,216,120,0.28)',
            offsetX: 0,
            offsetY: 3
          } : {
            radius: 0,
            color: 'rgba(0,0,0,0)',
            offsetX: 0,
            offsetY: 0
          })
          .onClick(() => {
            this.switchVideoByIndex(index);
          })
      }, (item: string, index: number) => `${item}_${index}`)
    }
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .backgroundColor('rgba(8,12,20,0.22)')
    .border({
      width: 1,
      color: `${this.accentColor}22`
    })
    .borderRadius(22)
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
            ['rgba(8,10,18,0.08)', 0],
            ['rgba(8,10,18,0.18)', 0.30],
            ['rgba(8,10,18,0.72)', 1]
          ]
        })

      Column({ space: 16 }) {
        Row() {
          Column({ space: 2 }) {
            Text(this.minimalMode ? '专注计时' : '当前倒计时')
              .fontSize(10)
              .fontColor('rgba(255,255,255,0.54)')

            Text(this.timerDisplay)
              .fontSize(this.minimalMode ? 38 : 34)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .fontFamily('monospace')
              .opacity(this.minimalMode ? 0.99 : 0.97)
          }
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 14, right: 14, top: 10, bottom: 10 })
          .backgroundColor(this.minimalMode ? 'rgba(8,12,20,0.20)' : 'rgba(8,12,20,0.30)')
          .borderRadius(18)

          Blank()

          Button(this.minimalMode ? '退出极简' : '极简模式')
            .height(34)
            .fontSize(11)
            .fontColor('#F5F7FA')
            .padding({ left: 14, right: 14 })
            .backgroundColor('rgba(255,255,255,0.12)')
            .borderRadius(17)
            .onClick(() => {
              this.minimalMode = !this.minimalMode;
            })
        }
        .width('100%')
        .padding({ top: 6, bottom: 6 })

        Blank()

        if (!this.minimalMode) {
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
                      this.switchVideoByIndex(index);
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
          }
          .width('100%')
        }

        if (this.minimalMode) {
          this.buildVideoDots()
        }

        Row({ space: 8 }) {
          if (!this.minimalMode) {
            Button(this.videoMuted ? '声音开' : '声音关')
              .height(40)
              .fontSize(12)
              .fontColor('#F5F7FA')
              .padding({ left: 16, right: 16 })
              .backgroundColor('rgba(14,18,28,0.34)')
              .borderRadius(20)
              .onClick(() => {
                this.videoMuted = !this.videoMuted;
              })

            Button(this.videoPlaying ? '暂停陪学' : '继续陪学')
              .height(40)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1B2431')
              .padding({ left: 18, right: 18 })
              .linearGradient({
                angle: 90,
                colors: [
                  ['#FFE39A', 0],
                  ['#FFD878', 1]
                ]
              })
              .borderRadius(20)
              .shadow({
                radius: 14,
                color: 'rgba(255,216,120,0.24)',
                offsetX: 0,
                offsetY: 6
              })
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
          } else {
            Blank()
          }
        }
        .width('100%')
        .justifyContent(this.minimalMode ? FlexAlign.Center : FlexAlign.Center)
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
