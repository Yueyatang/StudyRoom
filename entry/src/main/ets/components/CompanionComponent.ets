import util from '@ohos.util';
import lottie, { AnimationItem } from '@ohos/lottie';
import { CompanionDailyTask, CompanionProgress } from '../common/StudyRoomTypes';

interface CompanionStage {
  level: number;
  title: string;
  subtitle: string;
  hint: string;
  unlockText: string;
  animationName: string;
  accentColor: string;
  glowColor: string;
  badgeText: string;
  skinName: string;
}

@Component
export struct CompanionComponent {
  @Prop continuousDays: number = 0;
  @Prop totalTomatoCount: number = 0;
  @Prop todayTomatoCount: number = 0;
  @Prop statsVersion: number = 0;
  @Prop animationName: string = 'cat_sleep.json';
  @Prop pendingAffinity: number = 0;
  @Prop dailyTasks: CompanionDailyTask[] = [];
  @Prop showLevelUpModal: boolean = false;
  @Prop unlockedStageTitle: string = '';
  @Prop unlockedStageReward: string = '';
  @Prop latestClaimSummary: string = '';
  onClaimAffinity: () => void = () => {};
  onDismissLevelUp: () => void = () => {};
  @Watch('onProgressChange') @Prop companionProgress: CompanionProgress = {
    level: 1,
    totalAffinity: 0,
    currentLevelAffinity: 0,
    nextLevelAffinity: 100
  };

  private readonly stages: CompanionStage[] = [
    {
      level: 1,
      title: '初遇陪伴',
      subtitle: '小猫刚住进自习室，会安静地陪你开始第一段专注。',
      hint: '继续积累默契值，角色会越来越熟悉你的学习节奏。',
      unlockText: '解锁基础陪伴动作',
      animationName: 'cat_sleep.json',
      accentColor: '#FFD29A',
      glowColor: 'rgba(255, 210, 154, 0.32)',
      badgeText: 'Lv.1 初遇',
      skinName: '奶油猫'
    },
    {
      level: 2,
      title: '抖耳回应',
      subtitle: '它已经开始回应你的努力，会用轻轻抖耳传递存在感。',
      hint: '完成更多番茄和任务，默契值满后就能继续升级。',
      unlockText: '解锁抖耳回应动作',
      animationName: 'black_cat_shake_ear.json',
      accentColor: '#B7C4D6',
      glowColor: 'rgba(183, 196, 214, 0.24)',
      badgeText: 'Lv.2 熟悉',
      skinName: '黑猫皮肤'
    },
    {
      level: 3,
      title: '安心陪读',
      subtitle: '它已经完全信任你，开始进入稳定陪读状态。',
      hint: '这个阶段很适合固定学习节奏，默契值会增长得更快。',
      unlockText: '解锁夜色陪读形态',
      animationName: 'black_cat_sleep.json',
      accentColor: '#9FA9C9',
      glowColor: 'rgba(159, 169, 201, 0.24)',
      badgeText: 'Lv.3 陪读',
      skinName: '夜色黑猫'
    },
    {
      level: 4,
      title: '活力搭子',
      subtitle: '角色开始变得更活泼，说明你们已经建立了高频陪学关系。',
      hint: '完成任务会带来额外默契值，适合冲刺下一等级。',
      unlockText: '解锁玩球互动动作',
      animationName: 'blue_cat_playball.json',
      accentColor: '#8ACBFF',
      glowColor: 'rgba(138, 203, 255, 0.26)',
      badgeText: 'Lv.4 活力',
      skinName: '晴空蓝猫'
    },
    {
      level: 5,
      title: '深度默契',
      subtitle: '它会安静守着你，像一个真正熟悉你的学习搭子。',
      hint: '持续完成每日目标，会更快积累默契值。',
      unlockText: '解锁深海休憩皮肤',
      animationName: 'blue_cat_sleep.json',
      accentColor: '#9EE2FF',
      glowColor: 'rgba(158, 226, 255, 0.26)',
      badgeText: 'Lv.5 默契',
      skinName: '深海蓝猫'
    },
    {
      level: 6,
      title: '专属陪伴',
      subtitle: '你们已经成为非常稳定的陪学组合，解锁了更稀有的陪伴形态。',
      hint: '当前已达到最高等级，后续可以继续扩展隐藏动作与限定皮肤。',
      unlockText: '解锁限定翻滚动作',
      animationName: 'orange_cat_sleep_roll.json',
      accentColor: '#FFB26B',
      glowColor: 'rgba(255, 178, 107, 0.28)',
      badgeText: 'Lv.6 羁绊',
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

  private onProgressChange(): void {
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
    for (let index = this.stages.length - 1; index >= 0; index--) {
      if (this.companionProgress.level >= this.stages[index].level) {
        return this.stages[index];
      }
    }
    return this.stages[0];
  }

  private getNextStage(): CompanionStage | null {
    for (let index = 0; index < this.stages.length; index++) {
      if (this.stages[index].level > this.companionProgress.level) {
        return this.stages[index];
      }
    }
    return null;
  }

  private getAffinityProgress(): number {
    if (this.companionProgress.nextLevelAffinity <= 0) {
      return 1;
    }
    return Math.min(1, this.companionProgress.currentLevelAffinity / this.companionProgress.nextLevelAffinity);
  }

  private getAffinityProgressText(): string {
    if (this.companionProgress.level >= 6) {
      return '当前已达到最高陪伴等级。';
    }
    const remain: number = Math.max(0, this.companionProgress.nextLevelAffinity - this.companionProgress.currentLevelAffinity);
    return `再获得 ${remain} 点默契值即可升级。`;
  }

  private getStageAnimationName(): string {
    const stage: CompanionStage = this.getCurrentStage();
    return stage.animationName === '' ? this.animationName : stage.animationName;
  }

  private getTaskProgressText(task: CompanionDailyTask): string {
    return `${Math.min(task.progress, task.target)}/${task.target}`;
  }

  private getTaskStatusText(task: CompanionDailyTask): string {
    if (task.claimed) {
      return '已完成';
    }
    if (task.completed) {
      return '可领取';
    }
    return '进行中';
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
    Stack() {
      Scroll() {
        this.buildContent(this.getCurrentStage(), this.getNextStage())
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Auto)

      if (this.showLevelUpModal) {
        this.buildLevelUpModal(this.getCurrentStage())
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private buildContent(stage: CompanionStage, nextStage: CompanionStage | null): void {
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

      Column({ space: 14 }) {
        Row() {
          Text(`Lv.${this.companionProgress.level} ${stage.title}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Blank()

          Text(`${this.companionProgress.currentLevelAffinity}/${this.companionProgress.nextLevelAffinity} 默契值`)
            .fontSize(12)
            .fontColor(stage.accentColor)
        }
        .width('100%')

        Stack({ alignContent: Alignment.Start }) {
          Row()
            .width('100%')
            .height(8)
            .backgroundColor('rgba(255,255,255,0.10)')
            .borderRadius(4)

          Row()
            .width(`${this.getAffinityProgress() * 100}%`)
            .height(8)
            .backgroundColor(stage.accentColor)
            .borderRadius(4)
        }
        .width('100%')

        Text(this.getAffinityProgressText())
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.66)')
          .width('100%')
          .textAlign(TextAlign.Start)
      }
      .width('90%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('rgba(255,255,255,0.08)')
      .borderRadius(24)

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
              this.currentLoadedAnimation = '';
              void this.loadAnimation();
            })

          Column({ space: 8 }) {
            Text(stage.badgeText)
              .fontSize(12)
              .fontColor(stage.accentColor)
              .fontWeight(FontWeight.Medium)

            Text(stage.skinName)
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
        Column({ space: 8 }) {
          Text('待领取默契值')
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.60)')
            .width('100%')
            .textAlign(TextAlign.Start)

          Text(`${this.pendingAffinity}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD878')
            .width('100%')
            .textAlign(TextAlign.Start)

          Text(this.latestClaimSummary === '' ? '完成番茄、推进任务、达成目标后，会先累积到这里。' : this.latestClaimSummary)
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.66)')
            .width('100%')
            .textAlign(TextAlign.Start)
            .lineHeight(20)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button(this.pendingAffinity > 0 ? `领取 ${this.pendingAffinity}` : '暂无奖励')
          .enabled(this.pendingAffinity > 0)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.pendingAffinity > 0 ? '#1A2432' : 'rgba(255,255,255,0.36)')
          .height(42)
          .padding({ left: 18, right: 18 })
          .backgroundColor(this.pendingAffinity > 0 ? '#FFD878' : 'rgba(255,255,255,0.10)')
          .borderRadius(20)
          .onClick(() => {
            this.onClaimAffinity();
          })
      }
      .width('90%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('rgba(255,255,255,0.08)')
      .borderRadius(24)

      Column({ space: 12 }) {
        Row() {
          Text('每日互动任务')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Blank()

          Text('像游戏任务列表一样完成它们')
            .fontSize(11)
            .fontColor('rgba(255,255,255,0.56)')
        }
        .width('100%')

        ForEach(this.dailyTasks, (task: CompanionDailyTask) => {
          Row({ space: 12 }) {
            Column({ space: 6 }) {
              Text(task.title)
                .fontSize(15)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .width('100%')
                .textAlign(TextAlign.Start)

              Text(task.description)
                .fontSize(12)
                .fontColor('rgba(255,255,255,0.64)')
                .width('100%')
                .textAlign(TextAlign.Start)
                .lineHeight(20)

              Row({ space: 8 }) {
                Text(`奖励 +${task.reward}`)
                  .fontSize(11)
                  .fontColor('#FFD878')
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .backgroundColor('rgba(255,216,120,0.12)')
                  .borderRadius(12)

                Text(this.getTaskProgressText(task))
                  .fontSize(11)
                  .fontColor('rgba(255,255,255,0.58)')
              }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Text(this.getTaskStatusText(task))
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(task.claimed ? 'rgba(255,255,255,0.40)' : task.completed ? '#9EE2FF' : '#FFD878')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(task.claimed ? 'rgba(255,255,255,0.08)' : task.completed ? 'rgba(158,226,255,0.14)' : 'rgba(255,216,120,0.12)')
              .borderRadius(14)
          }
          .width('100%')
          .padding({ left: 14, right: 14, top: 14, bottom: 14 })
          .backgroundColor('rgba(255,255,255,0.06)')
          .borderRadius(20)
        }, (task: CompanionDailyTask) => task.id)
      }
      .width('90%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('rgba(255,255,255,0.08)')
      .borderRadius(24)

      Row({ space: 12 }) {
        this.buildStatCard('连续天数', `${this.continuousDays} 天`, stage.accentColor)
        this.buildStatCard('累计番茄', `${this.totalTomatoCount} 个`, stage.accentColor)
        this.buildStatCard('今日完成', `${this.todayTomatoCount} 个`, stage.accentColor)
      }
      .width('90%')

      Column({ space: 12 }) {
        this.buildInfoCard('当前皮肤', stage.skinName, '#FFFFFF')
        this.buildInfoCard('当前台词', stage.hint, '#FFFFFF')
        this.buildInfoCard('累计默契值', `${this.companionProgress.totalAffinity}`, stage.accentColor)
        this.buildInfoCard('下一阶段', nextStage === null ? '已解锁全部阶段' : nextStage.title, stage.accentColor)
      }
      .width('90%')
      .margin({ bottom: 28 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildLevelUpModal(stage: CompanionStage): void {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(3,7,14,0.62)')

      Column({ space: 14 }) {
        Text('升级成功')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')

        Text(`已解锁 Lv.${this.companionProgress.level} · ${this.unlockedStageTitle}`)
          .fontSize(15)
          .fontColor(stage.accentColor)

        Text(this.unlockedStageReward)
          .fontSize(14)
          .fontColor('rgba(255,255,255,0.72)')
          .textAlign(TextAlign.Center)
          .lineHeight(22)

        Text(`当前皮肤：${stage.skinName}`)
          .fontSize(13)
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('rgba(255,255,255,0.08)')
          .borderRadius(14)

        Button('我知道了')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A2432')
          .height(42)
          .padding({ left: 24, right: 24 })
          .backgroundColor('#FFD878')
          .borderRadius(21)
          .onClick(() => {
            this.onDismissLevelUp();
          })
      }
      .width('76%')
      .padding({ left: 18, right: 18, top: 24, bottom: 24 })
      .backgroundColor('rgba(18,24,34,0.96)')
      .border({
        width: 1,
        color: stage.accentColor
      })
      .borderRadius(28)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
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
