// App.tsx
import { useEffect, useState } from "react";
import { debugData, fetchNui, useNuiEvent } from "../utils/utils";
debugData([{ action: "setVisible", data: true }]);


// This is the main component that will be rendered.
const App: React.FC = () => {
	const [data, setData] = useState<any>({});
	const [headshot, setHeadshot] = useState<any>({});
	useEffect(() => {
		const keyHandler = (e: KeyboardEvent) => {
			if (["Backspace", "Escape"].includes(e.code)) {
				fetchNui("exit");
				console.log('Escape Key Pressed');
			}
		};

		window.addEventListener("keydown", keyHandler);
		return () => window.removeEventListener("keydown", keyHandler);
	}, []);

	useNuiEvent('setID', (data: any) => {
		console.log(JSON.stringify(data));
		setData(data)
	})
	useNuiEvent('setHeadshot', (data: any) => {
		setHeadshot(data)
	})
	return (
		<div className="container mx-auto mr-2 p-4 overflow-hidden">
			<div className="id-card flex bg-black w-[460px] h-[200px] rounded-2xl shadow-lg overflow-hidden text-white text-lg ml-auto mr-4 mt-4">
				<div className="id-card-left w-[45%] bg-gray-800 flex justify-center items-center p-4">
					<img id="face-image" src="https://www.pngkey.com/png/detail/349-3499617_person-placeholder-person-placeholder.png" alt="Player Face" className="photo w-full h-[130px] object-cover rounded-lg border-4 border-white shadow-md" />
				</div>
				<div className="id-card-right w-full p-8 flex flex-col justify-center gap-1">
					<h2 id="player-name" className="text-xl font-bold text-white">{data.firstname} {data.name}</h2>
					<p className="text-md font-medium text-gray-400"><strong className="font-bold text-orange-500">First Name:</strong> <span id="first-name" className="text-white">{data.firstname}</span></p>
					<p className="text-md font-medium text-gray-400"><strong className="font-bold text-orange-500">Last Name:</strong> <span id="last-name" className="text-white">{data.name}</span></p>
					<p className="text-md font-medium text-gray-400"><strong className="font-bold text-orange-500">Age:</strong> <span id="player-age" className="text-white">{data.age}</span></p>
					<p className="text-md font-medium text-gray-400"><strong className="font-bold text-orange-500">Register ID:</strong> <span id="register-id" className="text-white">{data.registration}</span></p>
					<p className="text-md font-medium text-gray-400"><strong className="font-bold text-orange-500">Phone:</strong> <span id="phone" className="text-gray-500 italic">+1 {data.phone}</span></p>
				</div>
			</div>
		</div>
	);
};

export default App;
