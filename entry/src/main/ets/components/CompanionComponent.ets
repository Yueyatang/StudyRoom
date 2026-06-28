import lottie, { AnimationItem } from '@ohos/lottie';

@Component
export struct CompanionComponent {
  @Prop continuousDays: number = 0;
  @Prop totalTomatoCount: number = 0;
  @Prop todayTomatoCount: number = 0;
  @Prop animationName: string = 'cat_sleep.json';

  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  private animationItem: AnimationItem | null = null;
  private isAnimationReady: boolean = false;

  aboutToAppear() {
    this.isAnimationReady = false;
    lottie.bindContext2dToCoordinator(this.canvasContext);
  }

  aboutToDisappear() {
    if (this.animationItem !== null) {
      this.animationItem.destroy();
      this.animationItem = null;
    }
    lottie.unbindContext2dFromCoordinator(this.canvasContext);
  }

  private getLevelText(): string {
    if (this.totalTomatoCount < 10) {
      return '初来乍到';
    }
    if (this.totalTomatoCount < 30) {
      return '熟悉陪伴';
    }
    if (this.totalTomatoCount < 80) {
      return '默契同桌';
    }
    if (this.totalTomatoCount < 180) {
      return '深度伴学';
    }
    return '沉浸搭子';
  }

  private getMoodText(): string {
    if (this.todayTomatoCount >= 8) {
      return '今天状态很棒，猫咪已经安心打盹了。';
    }
    if (this.todayTomatoCount >= 4) {
      return '节奏很稳，猫咪正陪你安静守住专注感。';
    }
    if (this.todayTomatoCount >= 1) {
      return '已经开始进入学习状态，继续保持就很好。';
    }
    return '先开始第一轮专注吧，猫咪会一直陪着你。';
  }

  private getHintText(): string {
    if (this.continuousDays >= 7) {
      return '你已经连续学习很多天了，记得也给自己留一点放松时间。';
    }
    if (this.continuousDays >= 3) {
      return '连击已经形成，今天再完成几轮就能把节奏彻底稳住。';
    }
    return '建立固定学习仪式感，比一口气冲太猛更重要。';
  }

  private playAnimation() {
    if (this.isAnimationReady) {
      return;
    }
    this.isAnimationReady = true;
    this.canvasContext.imageSmoothingEnabled = true;
    this.canvasContext.imageSmoothingQuality = 'medium';
    lottie.setAttachedCanvasHasVisibleArea(this.canvasContext, true);
    if (this.animationItem !== null) {
      this.animationItem.destroy();
      this.animationItem = null;
    }
    this.animationItem = lottie.loadAnimation({
      container: this.canvasContext,
      renderer: 'canvas',
      loop: true,
      autoplay: true,
      name: 'cat_sleep',
      contentMode: 'Contain',
      autoSkip: false,
      frameRate: 30,
      path: 'common/lottie/cat_sleep.json'
    });
    this.animationItem.addEventListener('DOMLoaded', () => {
      this.animationItem?.resize();
      this.animationItem?.setSpeed(1);
      this.animationItem?.play();
    });
    this.animationItem.addEventListener('enterFrame', () => {
      lottie.setAttachedCanvasHasVisibleArea(this.canvasContext, true);
    });
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        Column({ space: 10 }) {
          Text('陪伴角色')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width('100%')
            .textAlign(TextAlign.Start)

          Text('猫咪正在自习室里陪你一起安静学习。')
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.72)')
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .width('90%')
        .margin({ top: 24 })

        Column() {
          Stack({ alignContent: Alignment.Bottom }) {
            Column()
              .width('100%')
              .height(320)
              .borderRadius(32)
              .linearGradient({
                angle: 180,
                colors: [
                  ['rgba(255,255,255,0.16)', 0],
                  ['rgba(255,255,255,0.05)', 1]
                ]
              })

            Canvas(this.canvasContext)
              .width('100%')
              .height(320)
              .backgroundColor('rgba(255,255,255,0.03)')
              .onReady(() => {
                this.playAnimation();
              })

            Column({ space: 8 }) {
              Text('陪伴状态')
                .fontSize(12)
                .fontColor('rgba(255,255,255,0.56)')

              Text('猫咪熟睡中')
                .fontSize(14)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Medium)
            }
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor('rgba(10,14,22,0.32)')
            .borderRadius(18)
            .margin({ bottom: 18 })
          }
        }
        .width('90%')
        .clip(true)
        .backgroundColor('rgba(255,255,255,0.08)')
        .border({
          width: 1,
          color: 'rgba(255,255,255,0.10)'
        })
        .borderRadius(32)

        Row({ space: 12 }) {
          this.buildStatCard('连续天数', `${this.continuousDays} 天`)
          this.buildStatCard('累计番茄', `${this.totalTomatoCount} 个`)
          this.buildStatCard('今日完成', `${this.todayTomatoCount} 个`)
        }
        .width('90%')

        Column({ space: 12 }) {
          this.buildInfoCard('陪伴等级', this.getLevelText())
          this.buildInfoCard('当前状态', this.getMoodText())
          this.buildInfoCard('贴心提醒', this.getHintText())
        }
        .width('90%')
        .margin({ bottom: 28 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Auto)
  }

  @Builder
  private buildStatCard(title: string, value: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(12)
        .fontColor('rgba(255,255,255,0.60)')

      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor('rgba(255,255,255,0.08)')
    .borderRadius(24)
  }

  @Builder
  private buildInfoCard(title: string, content: string) {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontColor('rgba(255,255,255,0.58)')
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(content)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .width('100%')
        .textAlign(TextAlign.Start)
        .lineHeight(24)
    }
    .width('100%')
    .padding({ left: 18, right: 18, top: 16, bottom: 16 })
    .backgroundColor('rgba(255,255,255,0.08)')
    .borderRadius(22)
  }
}
