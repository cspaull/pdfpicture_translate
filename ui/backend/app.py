from flask import Flask, request, send_file, jsonify
from flask_cors import CORS
import os
import uuid
from werkzeug.utils import secure_filename
import fitz  # PyMuPDF
import easyocr
from deep_translator import GoogleTranslator
from PIL import Image, ImageDraw, ImageFont
import numpy as np
import io
import re
from sklearn.cluster import DBSCAN

# === Config ===
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')
OUTPUT_FOLDER = os.path.join(BASE_DIR, 'outputs')
ALLOWED_EXTENSIONS = {'pdf'}

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# =========================
# PDF Image Translator Class
# =========================

class PDFImageTranslator:
    def __init__(self, source_lang='id', target_lang='vi'):
        ocr_langs = [source_lang] if source_lang else ['id']
        self.reader = easyocr.Reader(ocr_langs, gpu=False)  # CPU mode
        self.source_lang = source_lang
        self.target_lang = target_lang

    def translate_pdf(self, input_pdf_path, output_pdf_path, progress_callback=None):
        pdf_document = fitz.open(input_pdf_path)
        new_pdf = fitz.open()
        total_pages = len(pdf_document)

        for page_num in range(total_pages):
            print(f"📝 Processing page {page_num + 1}/{total_pages}...")

            if progress_callback:
                progress_callback(page_num / total_pages)

            page = pdf_document[page_num]
            mat = fitz.Matrix(2.0, 2.0)
            pix = page.get_pixmap(matrix=mat)
            img_data = pix.tobytes("png")

            image = Image.open(io.BytesIO(img_data)).convert("RGB")
            results = self.reader.readtext(np.array(image))

            panels = self.cluster_text(results)
            new_image = image.copy()
            draw = ImageDraw.Draw(new_image)

            for panel in panels:
                panel_texts = []
                panel_bboxes = []
                for (bbox, text, confidence) in panel:
                    if confidence > 0.5:
                        if self.source_lang == 'id':
                            text = self.clean_indonesian_text(text)
                        panel_texts.append(text)
                        panel_bboxes.append(bbox)

                if not panel_texts:
                    continue

                full_text = ' '.join(panel_texts)
                try:
                    translated_text = GoogleTranslator(
                        source=self.source_lang, target=self.target_lang
                    ).translate(full_text)

                    if self.target_lang == 'vi':
                        translated_text = self.format_vietnamese_text(translated_text)

                    # Bounding box
                    x1 = min(int(b[0][0]) for b in panel_bboxes)
                    y1 = min(int(b[0][1]) for b in panel_bboxes)
                    x2 = max(int(b[2][0]) for b in panel_bboxes)
                    y2 = max(int(b[2][1]) for b in panel_bboxes)
                    box_width = x2 - x1
                    box_height = y2 - y1

                    draw.rectangle([x1, y1, x2, y2], fill='white')

                    font_size = max(10, min(box_height - 4, 24))
                    try:
                        font = self.get_font(font_size)
                    except:
                        font = ImageFont.load_default()

                    self.draw_text_in_box(draw, translated_text, x1, y1, box_width, box_height, font)

                    print(f"✅ '{full_text}' → '{translated_text}'")
                except Exception as e:
                    print(f"❌ Translation error '{full_text}': {e}")

            img_bytes = io.BytesIO()
            new_image.save(img_bytes, format='PNG')
            img_bytes.seek(0)

            new_page = new_pdf.new_page(width=page.rect.width, height=page.rect.height)
            new_page.insert_image(page.rect, stream=img_bytes.getvalue())

        if progress_callback:
            progress_callback(1.0)

        new_pdf.save(output_pdf_path)
        new_pdf.close()
        pdf_document.close()
        print(f"🎉 Completed! Translated PDF saved at: {output_pdf_path}")

    # ==== Helper functions ====

    def draw_text_in_box(self, draw, text, x, y, max_width, max_height, font):
        padding = 2
        x += padding
        y += padding
        max_width -= 2 * padding
        max_height -= 2 * padding

        words = text.split()
        lines = []
        current_line = []

        for word in words:
            test_line = ' '.join(current_line + [word])
            bbox = draw.textbbox((0, 0), test_line, font=font)
            text_width = bbox[2] - bbox[0]

            if text_width <= max_width:
                current_line.append(word)
            else:
                if current_line:
                    lines.append(' '.join(current_line))
                    current_line = [word]
                else:
                    lines.append(word)

        if current_line:
            lines.append(' '.join(current_line))

        bbox = draw.textbbox((0, 0), "Test", font=font)
        line_height = bbox[3] - bbox[1] + 2

        total_height = len(lines) * line_height
        if total_height > max_height:
            max_lines = max(1, int(max_height / line_height))
            lines = lines[:max_lines]
            if len(lines) > 0:
                lines[-1] += "..."

        current_y = y
        for line in lines:
            if current_y + line_height > y + max_height:
                break
            draw.text((x, current_y), line, fill='black', font=font)
            current_y += line_height

    def cluster_text(self, results, eps=60, min_samples=1):
        if not results:
            return []

        centers = [((bbox[0][0] + bbox[2][0]) / 2, (bbox[0][1] + bbox[2][1]) / 2) for (bbox, _, _) in results]
        clustering = DBSCAN(eps=eps, min_samples=min_samples).fit(centers)

        max_label = max(clustering.labels_) if len(clustering.labels_) > 0 else -1
        panels = [[] for _ in range(max_label + 1)]

        for idx, label in enumerate(clustering.labels_):
            if label >= 0:
                panels[label].append(results[idx])

        return [panel for panel in panels if panel]

    def clean_indonesian_text(self, text):
        return re.sub(r'[^\w\s\.,!?\-()]', '', text).strip()

    def format_vietnamese_text(self, text):
        replacements = {'đ': 'đ', 'Đ': 'Đ'}
        for old, new in replacements.items():
            text = text.replace(old, new)
        return text

    def get_font(self, font_size):
        font_paths = [
            "/System/Library/Fonts/Arial.ttf",
            "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
            "C:/Windows/Fonts/arial.ttf",
        ]
        for path in font_paths:
            if os.path.exists(path):
                return ImageFont.truetype(path, font_size)
        return ImageFont.load_default()

# ==== Flask Routes ====

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/translate-pdf', methods=['POST'])
def translate_pdf():
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400

        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400

        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type. Only PDF files are allowed'}), 400

        source_lang = request.form.get('source_lang', 'id')
        target_lang = request.form.get('target_lang', 'vi')

        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4().hex[:8]}_{filename}"
        input_path = os.path.join(UPLOAD_FOLDER, unique_filename)
        file.save(input_path)

        base_name = os.path.splitext(filename)[0][:30]  # Limit length
        output_filename = f"{uuid.uuid4().hex[:8]}_{base_name}_translated_{target_lang}.pdf"
        output_path = os.path.join(OUTPUT_FOLDER, output_filename)

        print(f"📂 Input path: {input_path}")
        print(f"📂 Output path: {output_path}")

        translator = PDFImageTranslator(source_lang=source_lang, target_lang=target_lang)
        translator.translate_pdf(input_path, output_path)

        os.remove(input_path)  # Clean up

        return send_file(
            output_path,
            as_attachment=True,
            download_name=output_filename,
            mimetype='application/pdf'
        )

    except Exception as e:
        print(f"Error during translation: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'message': 'PDF Translator API is running'})

@app.route('/supported-languages', methods=['GET'])
def get_supported_languages():
    languages = {
        'id': 'Bahasa Indonesia',
        'vi': 'Tiếng Việt',
        'en': 'English',
        'zh': 'Chinese',
        'ja': 'Japanese',
        'ko': 'Korean',
        'th': 'Thai',
    }
    return jsonify(languages)

if __name__ == '__main__':
    print("🚀 Starting PDF Translator API...")
    print("📱 Flutter app can connect to: http://localhost:8000")
    app.run(host='0.0.0.0', port=8000, debug=True)
