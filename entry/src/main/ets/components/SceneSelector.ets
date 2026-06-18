import { SceneData } from '../common/StudyRoomTypes';

@Component
export struct SceneSelector {
  @Prop scenes: SceneData[] = [];
  @Prop currentSceneIndex: number = 0;
  onSceneChange: (index: number) => void = () => {};
  onRandomScene: () => void = () => {};

  build() {
    Column() {
      if (this.scenes.length > 0) {
        Row() {
          Text('今日自习室')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
          Blank()
          Button('随机进入')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .height(32)
            .backgroundColor('rgba(255,255,255,0.16)')
            .borderRadius(16)
            .onClick(() => {
              this.onRandomScene();
            })
        }
        .width('90%')
        .margin({ top: 16, bottom: 10 })

        Row() {
          ForEach(this.scenes, (scene: SceneData, index: number) => {
            Column() {
              Text(scene.name)
                .fontSize(14)
                .fontColor(this.currentSceneIndex === index ? '#FFFFFF' : '#F3F3F3')
                .fontWeight(this.currentSceneIndex === index ? FontWeight.Bold : FontWeight.Normal)
              Text(scene.suggestion)
                .fontSize(10)
                .fontColor(this.currentSceneIndex === index ? '#FFF8D8' : '#D8D8D8')
                .maxLines(1)
                .margin({ top: 4 })
            }
            .width('32%')
            .height(62)
            .justifyContent(FlexAlign.Center)
            .padding({ left: 8, right: 8 })
            .borderRadius(22)
            .backgroundColor(this.currentSceneIndex === index ? scene.accentColor : 'rgba(255,255,255,0.10)')
            .onClick(() => {
              this.onSceneChange(index);
            })
          })
        }
        .width('90%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 14 })

        Column() {
          Row() {
            Column() {
              Text(this.scenes[this.currentSceneIndex].atmosphere)
                .fontSize(13)
                .fontColor('#F5F7FA')
              Text(`推荐专注：${this.scenes[this.currentSceneIndex].suggestion}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .margin({ top: 8 })
              Text(this.scenes[this.currentSceneIndex].quote)
                .fontSize(12)
                .fontColor('#D7DBE0')
                .maxLines(2)
                .margin({ top: 10 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Column() {
              Text('环境音')
                .fontSize(11)
                .fontColor('#D9D9D9')
              Text(this.scenes[this.currentSceneIndex].musicLabel)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .margin({ top: 6 })
              Text(this.scenes[this.currentSceneIndex].soundLabel)
                .fontSize(10)
                .fontColor('#C8CDD3')
                .maxLines(1)
                .margin({ top: 6 })
            }
            .padding({ left: 12, right: 12, top: 12, bottom: 12 })
            .backgroundColor('rgba(255,255,255,0.10)')
            .borderRadius(18)
          }
          .width('100%')
        }
        .width('90%')
        .padding(18)
        .backgroundColor('rgba(18,22,30,0.28)')
        .borderRadius(28)
        .margin({ bottom: 16 })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
