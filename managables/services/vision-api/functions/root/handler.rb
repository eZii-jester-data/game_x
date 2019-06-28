require 'tempfile'
require 'json'
require 'byebug'
require "google/cloud/vision"
require "base64"


def handler event
	t = Tempfile.new(['google', '.json'])

	google_json_contents = JSON.parse(event.context)["google_json_contents"]


	File.open(t.path, 'w') do |file|
		file.write(google_json_contents)
	end

	ENV['GOOGLE_APPLICATION_CREDENTIALS'] = t.path

	base_64_image = JSON.parse(event.body)["data"].gsub("data:image/jpeg;base64,", '')

	image_path = base_64_image_to_local_tempfile_path(base_64_image)

	result = ocr_document_image(image_path)

	response = {
		'message' => result
	}

	render json: response
end

def ocr_document_image(image_path)
	image_annotator = Google::Cloud::Vision::ImageAnnotator.new

	response = image_annotator.document_text_detection image: image_path

	text = ""
	response.responses.each do |res|
		res.text_annotations.each do |annotation|
			text << annotation.description
		end
	end

	return text
end

def base_64_image_to_local_tempfile_path(base_64_image)
	t = Tempfile.new(['image', '.jpg'])

	base_64_decoded_image = Base64.decode64(base_64_image)

	File.binwrite(t.path, base_64_decoded_image)

	return t.path
end
