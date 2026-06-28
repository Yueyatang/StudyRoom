import util from '@ohos.util';
import lottie, { AnimationItem } from '@ohos/lottie';

interface CompanionStage {
  minTomatoes: number;
  title: string;
  subtitle: string;
  hint: string;
  animationName: string;
  accentColor: string;
  glowColor: string;
  badgeText: string;
  skinName: string;
}

@Component
export struct CompanionComponent {
  @Prop continuousDays: number = 0;
  @Watch('onTomatoProgressChange') @Prop totalTomatoCount: number = 0;
  @Prop todayTomatoCount: number = 0;
  @Watch('onTomatoProgressChange') @Prop statsVersion: number = 0;
  @Prop animationName: string = 'cat_sleep.json';

  private readonly stages: CompanionStage[] = [
    {
      minTomatoes: 0,
      title: '初遇陪伴',
      subtitle: '小猫刚住进自习室，会安静地陪你开始第一段专注。',
      hint: '先完成今天的第一轮番茄，小猫会慢慢熟悉你的学习节奏。',
      animationName: 'cat_sleep.json',
      accentColor: '#FFD29A',
      glowColor: 'rgba(255, 210, 154, 0.32)',
      badgeText: '基础动作',
      skinName: '奶油猫'
    },
    {
      minTomatoes: 4,
      title: '抖耳回应',
      subtitle: '你已经不是陌生人了，它会用轻轻抖耳来回应你的努力。',
      hint: '累计完成 4 个番茄后，陪伴角色开始出现更明显的互动动作。',
      animationName: 'black_cat_shake_ear.json',
      accentColor: '#B7C4D6',
      glowColor: 'rgba(183, 196, 214, 0.24)',
      badgeText: '动作解锁',
      skinName: '黑猫皮肤'
    },
    {
      minTomatoes: 10,
      title: '安心陪读',
      subtitle: '它已经完全信任你，进入了稳定陪读状态。',
      hint: '这个阶段很适合建立固定学习习惯，让陪伴感真正形成记忆点。',
      animationName: 'black_cat_sleep.json',
      accentColor: '#9FA9C9',
      glowColor: 'rgba(159, 169, 201, 0.24)',
      badgeText: '稳定阶段',
      skinName: '夜色黑猫'
    },
    {
      minTomatoes: 18,
      title: '活力玩球',
      subtitle: '高频专注被它看见了，猫咪开始用更活泼的动作陪你冲刺。',
      hint: '连续保持专注输出时，角色会切换到更有活力的陪伴动作。',
      animationName: 'blue_cat_playball.json',
      accentColor: '#8ACBFF',
      glowColor: 'rgba(138, 203, 255, 0.26)',
      badgeText: '活力动作',
      skinName: '晴空蓝猫'
    },
    {
      minTomatoes: 28,
      title: '深度默契',
      subtitle: '它会安静地守着你，说明你们已经建立起稳定默契。',
      hint: '这个阶段建议提高每日目标，让陪伴角色和你的成长一起推进。',
      animationName: 'blue_cat_sleep.json',
      accentColor: '#9EE2FF',
      glowColor: 'rgba(158, 226, 255, 0.26)',
      badgeText: '默契进阶',
      skinName: '深海蓝猫'
    },
    {
      minTomatoes: 40,
      title: '隐藏皮肤',
      subtitle: '资深陪学搭子已上线，翻滚入睡是只对长期坚持者开放的奖励。',
      hint: '后面还可以继续追加更多隐藏动作、节日皮肤和专属台词。',
      animationName: 'orange_cat_sleep_roll.json',
      accentColor: '#FFB26B',
      glowColor: 'rgba(255, 178, 107, 0.28)',
      badgeText: '终极解锁',
      skinName: '橘猫限定'
    }
  ];

  private renderingSettings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasRenderingContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.renderingSettings);
  private animateItem: AnimationItem | null = null;
  private readonly animateName: string = 'companion_animation';
  private lottieDataCache: Map<string, Object> = new Map<string, Object>();
  private currentLoadedAnimation: string = '';
  private isLoading: boolean = false;

  aboutToAppear(): void {
    void this.loadAnimation();
  }

  aboutToDisappear(): void {
    this.destroyAnimation();
  }

  private onTomatoProgressChange(): void {
    void this.loadAnimation();
  }

  private destroyAnimation(): void {
    if (this.animateItem !== null) {
      lottie.destroy(this.animateName);
      this.animateItem = null;
    }
    this.currentLoadedAnimation = '';
  }

  private getCurrentStage(): CompanionStage {
    let stage: CompanionStage = this.stages[0];
    this.stages.forEach((item: CompanionStage) => {
      if (this.totalTomatoCount >= item.minTomatoes) {
        stage = item;
      }
    });
    return stage;
  }

  private getNextStage(): CompanionStage | null {
    for (let index = 0; index < this.stages.length; index++) {
      if (this.stages[index].minTomatoes > this.totalTomatoCount) {
        return this.stages[index];
      }
    }
    return null;
  }

  private getStageProgressText(): string {
    const nextStage: CompanionStage | null = this.getNextStage();
    if (nextStage === null) {
      return '已解锁全部陪伴动作与皮肤，可以继续扩展隐藏奖励。';
    }
    const remain: number = nextStage.minTomatoes - this.totalTomatoCount;
    return `距离下一阶段还差 ${remain} 个番茄。`;
  }

  private getStageAnimationName(): string {
    const stage: CompanionStage = this.getCurrentStage();
    if (stage.animationName !== '') {
      return stage.animationName;
    }
    return this.animationName;
  }

  private async ensureLottieData(fileName: string): Promise<void> {
    if (this.lottieDataCache.has(fileName) || this.isLoading) {
      return;
    }
    this.isLoading = true;
    try {
      const data: Uint8Array = getContext(this).resourceManager.getRawFileContentSync(fileName);
      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const jsonString: string = decoder.decodeToString(new Uint8Array(data));
      this.lottieDataCache.set(fileName, JSON.parse(jsonString) as Object);
    } catch (error) {
      console.error(`[CompanionComponent] load raw lottie failed: ${JSON.stringify(error)}`);
    } finally {
      this.isLoading = false;
    }
  }

  private async loadAnimation(): Promise<void> {
    const fileName: string = this.getStageAnimationName();
    if (this.currentLoadedAnimation === fileName && this.animateItem !== null) {
      this.animateItem.play();
      return;
    }

    await this.ensureLottieData(fileName);
    const animationData: Object | undefined = this.lottieDataCache.get(fileName);
    if (animationData === undefined) {
      return;
    }

    this.destroyAnimation();
    this.currentLoadedAnimation = fileName;
    this.animateItem = lottie.loadAnimation({
      container: this.canvasRenderingContext,
      renderer: 'canvas',
      loop: true,
      autoplay: true,
      name: this.animateName,
      contentMode: 'Contain',
      frameRate: 30,
      autoSkip: false,
      animationData: animationData
    });
    this.animateItem.addEventListener('DOMLoaded', () => {
      this.animateItem?.resize();
      this.animateItem?.play();
    });
  }

  build(): void {
    this.buildContent(this.getCurrentStage());
  }

  @Builder
  private buildContent(stage: CompanionStage): void {
    Scroll() {
      Column({ space: 18 }) {
        Text(`${this.statsVersion}`)
          .width(0)
          .height(0)
          .opacity(0)

        Column({ space: 10 }) {
          Text('陪伴角色')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width('100%')
            .textAlign(TextAlign.Start)

          Text(stage.subtitle)
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.72)')
            .width('100%')
            .textAlign(TextAlign.Start)
            .lineHeight(22)
        }
        .width('90%')
        .margin({ top: 24 })

        Column() {
          Stack({ alignContent: Alignment.Bottom }) {
            Column()
              .width('100%')
              .height(330)
              .borderRadius(32)
              .linearGradient({
                angle: 180,
                colors: [
                  [stage.glowColor, 0],
                  ['rgba(255,255,255,0.05)', 1]
                ]
              })

            Canvas(this.canvasRenderingContext)
              .width(280)
              .height(280)
              .backgroundColor('rgba(255,255,255,0.03)')
              .onReady(() => {
                this.canvasRenderingContext.imageSmoothingEnabled = true;
                this.canvasRenderingContext.imageSmoothingQuality = 'medium';
                void this.loadAnimation();
              })

            Column({ space: 8 }) {
              Text(stage.badgeText)
                .fontSize(12)
                .fontColor(stage.accentColor)
                .fontWeight(FontWeight.Medium)

              Text(stage.title)
                .fontSize(15)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)
            }
            .padding({ left: 14, right: 14, top: 10, bottom: 10 })
            .backgroundColor('rgba(10,14,22,0.34)')
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
        .alignItems(HorizontalAlign.Center)

        Row({ space: 12 }) {
          this.buildStatCard('连续天数', `${this.continuousDays} 天`, stage.accentColor)
          this.buildStatCard('累计番茄', `${this.totalTomatoCount} 个`, stage.accentColor)
          this.buildStatCard('今日完成', `${this.todayTomatoCount} 个`, stage.accentColor)
        }
        .width('90%')

        Column({ space: 12 }) {
          this.buildInfoCard('当前动作', stage.title, stage.accentColor)
          this.buildInfoCard('当前皮肤', stage.skinName, '#FFFFFF')
          this.buildInfoCard('陪伴台词', stage.hint, '#FFFFFF')
          this.buildInfoCard('成长进度', this.getStageProgressText(), stage.accentColor)
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
  private buildStatCard(title: string, value: string, accentColor: string): void {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(12)
        .fontColor('rgba(255,255,255,0.60)')

      Text(value)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(accentColor)
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 16 })
    .backgroundColor('rgba(255,255,255,0.08)')
    .borderRadius(24)
  }

  @Builder
  private buildInfoCard(title: string, content: string, accentColor: string): void {
    Column({ space: 8 }) {
      Text(title)
        .fontSize(13)
        .fontColor('rgba(255,255,255,0.58)')
        .width('100%')
        .textAlign(TextAlign.Start)

      Text(content)
        .fontSize(16)
        .fontColor(accentColor)
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
