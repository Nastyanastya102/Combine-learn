import UIKit
import Photos
import Combine

class CollageNeueModel: ObservableObject {
  static let collageSize = CGSize(width: UIScreen.main.bounds.width, height: 200)
  private var subscriptions = Set<AnyCancellable>()
  private let images = CurrentValueSubject<[UIImage], Never>([])
  
  @Published var imagePreview: UIImage?
  // MARK: - Collage
  
  private(set) var lastSavedPhotoID = ""
  private(set) var lastErrorMessage = ""

  func bindMainView() {
    images
      .map { photos in
        UIImage.collage(images: photos, size: Self.collageSize)
      }
      .assign(to: &$imagePreview)
  }

  func add() {
    images.value.append(UIImage(named: "IMG_1907")!)
  }

  func clear() {
    images.send([])
  }

  func save() {
    
  }
  
  // MARK: -  Displaying photos picker
  private lazy var imageManager = PHCachingImageManager()
  private(set) var thumbnails = [String: UIImage]()
  private let thumbnailSize = CGSize(width: 200, height: 200)

  func bindPhotoPicker() {
    
  }
  
  func loadPhotos() -> PHFetchResult<PHAsset> {
    let allPhotosOptions = PHFetchOptions()
    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    return PHAsset.fetchAssets(with: allPhotosOptions)
  }

  func enqueueThumbnail(asset: PHAsset) {
    guard thumbnails[asset.localIdentifier] == nil else { return }
    
    imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
      guard let image = image else { return }
      self.thumbnails[asset.localIdentifier] = image
    })
  }
  
  func selectImage(asset: PHAsset) {
    imageManager.requestImage(
      for: asset,
      targetSize: UIScreen.main.bounds.size,
      contentMode: .aspectFill,
      options: nil
    ) { [weak self] image, info in
      guard let self = self,
            let image = image,
            let info = info else { return }
      
      if let isThumbnail = info[PHImageResultIsDegradedKey as String] as? Bool, isThumbnail {
        // Skip the thumbnail version of the asset
        return
      }
      
      // Send the selected image
    }
  }
}
