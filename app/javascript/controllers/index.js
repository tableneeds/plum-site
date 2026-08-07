// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import AssetCollectionController from "controllers/plum/asset_collection_controller"
import BlocksEditorController from "controllers/plum/blocks_editor_controller"
import BlueprintController from "controllers/plum/blueprint_controller"
import ConditionalFieldsController from "controllers/plum/conditional_fields_controller"
import FocalPointController from "controllers/plum/focal_point_controller"
import FormFieldsController from "controllers/plum/form_fields_controller"
import ImagePickerController from "controllers/plum/image_picker_controller"
import StructuredFieldController from "controllers/plum/structured_field_controller"
import ThemeSettingsController from "controllers/plum/theme_settings_controller"

eagerLoadControllersFrom("controllers", application)

// Plum 0.2.0's import-map directory does not participate reliably in dynamic
// controller discovery for external hosts. Register its packaged controllers
// explicitly until the upstream asset-path fix reaches a gem release.
application.register("plum--asset-collection", AssetCollectionController)
application.register("plum--blocks-editor", BlocksEditorController)
application.register("plum--blueprint", BlueprintController)
application.register("plum--conditional-fields", ConditionalFieldsController)
application.register("plum--focal-point", FocalPointController)
application.register("plum--form-fields", FormFieldsController)
application.register("plum--image-picker", ImagePickerController)
application.register("plum--structured-field", StructuredFieldController)
application.register("plum--theme-settings", ThemeSettingsController)
