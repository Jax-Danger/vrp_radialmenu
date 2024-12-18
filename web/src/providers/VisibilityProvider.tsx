import React, {
	Context,
	createContext,
	useContext,
	useEffect,
	useState,
} from "react";
import { useNuiEvent, fetchNui } from "../utils/utils";

const VisibilityCtx = createContext<VisibilityProviderValue | null>(null);

interface VisibilityProviderValue {
	setVisible: (visible: boolean) => void;
	visible: boolean;
}

export const VisibilityProvider: React.FC<{ children: React.ReactNode }> = ({
	children,
}) => {
	const [visible, setVisible] = useState(false);

	useNuiEvent<boolean>("setVisible", setVisible);

	// useEffect(() => {
	// 	if (!visible) return;
	// 	console.log("testing visible true")
	// 	const keyHandler = (e: KeyboardEvent) => {
	// 		if (["Backspace", "Escape"].includes(e.code)) {
	// 			fetchNui("exit");
	// 			console.log('Escape Key Pressed');
	// 			setVisible(false);
	// 		}
	// 	};

	// 	window.addEventListener("keydown", keyHandler);
	// 	return () => window.removeEventListener("keydown", keyHandler);
	// }, [visible]);

	return (
		<VisibilityCtx.Provider
			value={{
				visible,
				setVisible,
			}}
		>
			<div
				style={{ visibility: visible ? "visible" : "hidden", height: "100%" }}
			>
				{children}
			</div>
		</VisibilityCtx.Provider>
	);
};

export const useVisibility = () =>
	useContext<VisibilityProviderValue>(
		VisibilityCtx as Context<VisibilityProviderValue>
	);
