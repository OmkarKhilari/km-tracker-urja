from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import gspread
from oauth2client.service_account import ServiceAccountCredentials
import logging
import datetime

app = FastAPI()

# Set up CORS
origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:8000",
    "https://km-tracker-urja.netlify.app",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# Set up logging
logging.basicConfig(level=logging.DEBUG)

scope = ["https://spreadsheets.google.com/feeds", 'https://www.googleapis.com/auth/spreadsheets', "https://www.googleapis.com/auth/drive.file", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name('service-account.json', scope)
client = gspread.authorize(creds)

sheet_id = "19lBAT1N_Vuu-d1GAOGEfgZ1WAHFoHjglZRv3sIWiXKg" 

@app.options("/write/")
async def options_handler():
    return JSONResponse(content="OK", status_code=200)

@app.post("/write/")
async def write(request: Request):
    form = await request.json()

    if not form:
        raise HTTPException(status_code=400, detail="No data provided")
    
    branch = form.get('branch')
    name = form.get('name')
    designation = form.get('position')
    shift = form.get('day')  
    opening_km = float(form.get('openingKm'))
    closing_km = float(form.get('closingKm'))
    km_travelled = float(form.get('km_travelled_today'))
    is_sunday = form.get('is_sunday', False)
    daily_allowance = float(form.get('daily_allowance'))
    date = datetime.datetime.now().strftime("%Y-%m-%d")

    if not branch:
        raise HTTPException(status_code=400, detail="Branch not provided")

    try:
        # Load or create a sheet for the specified branch
        workbook = client.open_by_key(sheet_id)
        try:
            sheet = workbook.worksheet(branch)
        except gspread.WorksheetNotFound:
            sheet = workbook.add_worksheet(title=branch, rows="100", cols="50")
            # Initialize the sheet with headers if new
            headers = ["Name", "Designation", "Date", "Opening Km", "Closing Km", "KM Travelled Today", "Total DA"]
            sheet.append_row(headers)

        # Find or add employee row
        cell = sheet.find(name, in_column=1)
        if not cell:
            # New employee
            sheet.append_row([name, designation, date, opening_km, closing_km, km_travelled, daily_allowance])
        else:
            index = cell.row
            row_values = sheet.row_values(index)
            first_empty_col = len(row_values) + 1  # get index of the first empty cell in the row

            # Check if headers exist in the first empty cell column and add them if they don't
            headers_row = sheet.row_values(1)  # Assuming headers are always in the first row
            required_headers = ["Date", "Opening Km", "Closing Km", "KM Travelled Today", "Total DA"]

            if not all(header in headers_row[first_empty_col-1:first_empty_col+4] for header in required_headers):
                header_update_range = f"{chr(64 + first_empty_col)}1:{chr(64 + first_empty_col + 4)}1"
                sheet.update(header_update_range, [required_headers])

            # Append data in the first empty cell in the row for the same employee
            update_range = f"{chr(64 + first_empty_col)}{index}:{chr(64 + first_empty_col + 4)}{index}"
            sheet.update(update_range, [[date, opening_km, closing_km, km_travelled, daily_allowance]])

        return JSONResponse(content={"message": "Data written successfully"})
    except Exception as e:
        logging.exception("Error occurred while writing data:")
        raise HTTPException(status_code=500, detail="Internal Server Error")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
